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

  check: ->
    errors = @errors()

    if errors.length == 0
      @board.querySelector('.congratulations').classList.add('show')
    else
      alert errors.map((el) -> el.message).join()

  generate: (game, solution = false, cell_class = Nikoli.Cell) ->
    @game = game if game?

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
    @board.querySelector('.congratulations').classList.remove('show')

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
  constructor: (@x, @y, @game) ->
    @value = @game[@x][@y] if @game? && @valid()

  create: (value) ->
    cell = document.createElement 'div'
    cell.dataset.row = @x
    cell.dataset.column = @y

    cell.classList.add 'grid-cell'

    cell.innerHTML = '&nbsp;'

    cell

  toString: -> "#{@x};#{@y}"

  getColumn: ->
    column = []
    column.push @game[i][@y] for i in [0...@game.length]
    column

  getRow: -> @game[@x]

  adjacentCells: ->
    [
      new Cell(@x + 1, @y, @game),
      new Cell(@x - 1, @y, @game),
      new Cell(@x, @y + 1, @game),
      new Cell(@x, @y - 1, @game)
    ]

  valid: (value) ->
    0 <= @x < @game.length && 0 <= @y < @game[@x].length &&
      (!value? || value < 0 && @game[@x][@y] < 0 || value >= 0 && @game[@x][@y] >= 0)

  duplicatesIn: (array) ->
    array.filter((cell) => cell == @value).length > 1

  columnDuplicates: ->
    @duplicatesIn @getColumn()

  rowDuplicates: ->
    @duplicatesIn @getRow()

  squareDuplicates: (from, size) ->
    square = []
    for i in [from.x...(from.x + size)]
      for j in [from.y...(from.y + size)]
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
