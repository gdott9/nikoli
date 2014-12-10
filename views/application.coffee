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

  check: ->
    errors = @errors()

    if errors.length == 0
      alert 'Congratulations!'
    else
      alert errors.map((el) -> el.message).join()

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

class Nikoli.Cell
  constructor: (@x, @y, @game) ->
    @value = @game[@x][@y] if @valid()

  toString: -> "#{@x};#{@y}"

  adjacentCells: ->
    [
      new Cell(@x + 1, @y, @game),
      new Cell(@x - 1, @y, @game),
      new Cell(@x, @y + 1, @game),
      new Cell(@x, @y - 1, @game)
    ]

  isPool: ->
    [
      new Cell(@x, @y + 1, @game),
      new Cell(@x + 1, @y, @game),
      new Cell(@x + 1, @y + 1, @game),
    ].every (cell) => cell.valid(@value)

  valid: (value) ->
    0 <= @x < @game.length && 0 <= @y < @game[@x].length &&
      (!value? || value < 0 && @game[@x][@y] < 0 || value >= 0 && @game[@x][@y] >= 0)

  duplicatesIn: (array) ->
    array.filter((cell) => cell == @value).length > 1

  columnDuplicates: ->
    column = []
    column.push @game[i][@y] for i in [0...@game.length]

    @duplicatesIn column

  rowDuplicates: ->
    @duplicatesIn @game[@x]

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
