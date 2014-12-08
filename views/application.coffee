window.Nikoli = Nikoli = {}

class Nikoli.Stream
  constructor: (@game) ->
    @cells = []

  calculate: (cell) ->
    value = @game[cell.x][cell.y]
    @cells = []
    @type = if value < 0 then 'black' else 'white'

    cell = {x: cell.x, y: cell.y, value: value}
    cells_to_process = [cell]

    while cells_to_process.length > 0
      cell = cells_to_process.pop()
      cells_to_process = cells_to_process.concat @process(cell) unless @include(cell)


    @cells

  checkCell: (cell, value) ->
    0 <= cell.x < @game.length && 0 <= cell.y < @game[cell.x].length &&
      (value < 0 && @game[cell.x][cell.y] < 0 || value >= 0 && @game[cell.x][cell.y] >= 0)

  empty: ->
    @cells.length == 0

  getCell: (cell, value) ->
    {x: cell.x, y: cell.y, value: @game[cell.x][cell.y]} if @checkCell(cell, value)

  include: (cell) ->
    @cells.indexOf("#{cell.x};#{cell.y}") >= 0

  length: ->
    @cells.length

  process: (cell) ->
    @cells.push("#{cell.x};#{cell.y}")

    x = cell.x
    y = cell.y
    value = cell.value

    cells_to_add = []
    tmp_cell = @getCell({x: x+1, y: y}, value)
    cells_to_add.push tmp_cell if tmp_cell?
    tmp_cell = @getCell({x: x-1, y: y}, value)
    cells_to_add.push tmp_cell if tmp_cell?
    tmp_cell = @getCell({x: x, y: y+1}, value)
    cells_to_add.push tmp_cell if tmp_cell?
    tmp_cell = @getCell({x: x, y: y-1}, value)
    cells_to_add.push tmp_cell if tmp_cell?

    cells_to_add
