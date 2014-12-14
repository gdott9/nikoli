window.Nikoli = {}

class Nikoli.Game
  constructor: (@board, @name, @url) ->
    @name = 'nikoli' unless @name?
    @url = "/data/#{@name}" unless @url?

    @board.classList.add @name

    @grid = document.createElement 'div'
    @grid.classList.add 'game-container'
    @board.appendChild @grid

    @getFiles()

    buttons_div = document.createElement 'div'
    buttons = {check: 'Check', reset: 'Reset', newgame: 'New game', help: '?'}

    for k,v of buttons
      button = document.createElement 'button'
      button.innerHTML = v
      button.classList.add k

      buttons_div.appendChild button

    @board.appendChild buttons_div

    @board.querySelector('.check').addEventListener('click', @check.bind(this))
    @board.querySelector('.reset').addEventListener('click', @reset.bind(this))
    @board.querySelector('.newgame').addEventListener('click', @newgame.bind(this))

    congratulations = document.createElement 'div'
    congratulations.innerHTML = 'Congratulations!'
    congratulations.classList.add 'congratulations'
    congratulations.classList.add 'hide'
    @board.appendChild congratulations

    errors = document.createElement 'ul'
    errors.classList.add 'errors'
    errors.classList.add 'hide'
    @board.appendChild errors

  check: ->
    errors = @errors()

    if errors.length == 0
      [].forEach.call @board.querySelectorAll('.error'), (cell) ->
        cell.classList.remove 'error'
      @board.querySelector('.errors').classList.remove('show')
      @board.querySelector('.congratulations').classList.add('show')
    else
      errors_elem = @board.querySelector('.errors')
      errors_elem.innerHTML = ''

      errors.forEach (error) =>
        error_cell = @board.querySelector("[data-row=\"#{error.row}\"][data-column=\"#{error.column}\"]")
        error_cell.classList.add 'error'

        li = document.createElement('li')
        li.innerHTML = error.message

        errors_elem.appendChild li

      @board.querySelector('.congratulations').classList.remove('show')
      errors_elem.classList.add('show')

  generate: (game, solution = false, cell_class = Nikoli.Cell) ->
    @game = game if game?

    @board.querySelector('.congratulations').classList.remove('show')
    @board.querySelector('.errors').classList.remove('show')

    @grid.innerHTML = ''
    @game.forEach((row, i) =>
      row_elem = new Nikoli.Row().create()
      row.forEach((cell, j) ->
        row_elem.appendChild new cell_class(i, j).create(cell))

      @grid.appendChild row_elem)

    return

  getFiles: ->
    xmlhttp = new XMLHttpRequest()
    xmlhttp.open("GET", "#{@url}.json")

    xmlhttp.addEventListener('load', (evt) =>
      @setFiles JSON.parse(evt.target.responseText))
    xmlhttp.send()

  setFiles: (files) ->
    @files = files
    @file = @files[0]

    @newgame() unless @game?

  newgame: ->
    xmlhttp = new XMLHttpRequest()
    xmlhttp.open("GET", "#{@url}/#{@file}.json")

    xmlhttp.addEventListener('load', (evt) =>
      @generate JSON.parse(evt.target.responseText))
    xmlhttp.send()

  reset: ->
    @generate()

class Nikoli.Row
  create: ->
    row = document.createElement 'div'
    row.classList.add 'grid-row'

    row

class Nikoli.Cell
  constructor: (@row, @column, @game) ->
    @value = @game[@row][@column] if @game? && @valid()

  create: (value) ->
    cell = document.createElement 'div'
    cell.dataset.row = @row
    cell.dataset.column = @column

    cell.classList.add 'grid-cell'

    cell.innerHTML = '&nbsp;'

    cell

  toString: -> "#{@row};#{@column}"

  getColumn: ->
    column = []
    column.push @game[i][@column] for i in [0...@game.length]
    column

  getRow: -> @game[@row]

  adjacentCells: ->
    constructor = Object.getPrototypeOf(this).constructor
    [
      new constructor(@row + 1, @column, @game),
      new constructor(@row - 1, @column, @game),
      new constructor(@row, @column + 1, @game),
      new constructor(@row, @column - 1, @game)
    ]

  valid: (value) ->
    0 <= @row < @game.length && 0 <= @column < @game[@row].length &&
      (!value? || value < 0 && @game[@row][@column] < 0 || value >= 0 && @game[@row][@column] >= 0)

  duplicatesIn: (array) ->
    array.filter((cell) => cell == @value).length > 1

  columnDuplicates: ->
    @duplicatesIn @getColumn()

  rowDuplicates: ->
    @duplicatesIn @getRow()

  squareDuplicates: (from, size) ->
    square = []
    for i in [from.row...(from.row + size)]
      for j in [from.column...(from.column + size)]
        square.push @game[i][j]

    @duplicatesIn square

class Nikoli.Stream
  constructor: (@game) ->
    @cells = []

  calculate: (cell) ->
    @cells = []
    @type = if cell.value < 0 then 'black' else 'white'

    cells_to_process = [cell]

    while cells_to_process.length > 0
      cell = cells_to_process.pop()
      cells_to_process = cells_to_process.concat @process(cell) unless @include(cell)

    @cells

  empty: ->
    @cells.length == 0

  include: (cell) ->
    @cells.indexOf(cell.toString()) >= 0

  length: ->
    @cells.length

  process: (cell) ->
    @cells.push(cell.toString())

    cell.adjacentCells().filter((adj_cell) -> adj_cell.valid(cell.value))
