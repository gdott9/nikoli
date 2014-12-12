class Nikoli.Akari extends Nikoli.Game
  constructor: (@board, @name = 'akari') ->
    super @board, @name

  errors: ->
    solution = @toArray()
    errors = []

    for i in [0...solution.length]
      row = solution[i]
      for j in [0...row.length]
        cell = new Nikoli.AkariCell(i, j, solution)

        if cell.value == -5
          errors.push {row: i, column: j, message: 'The light is illuminated by another one'}
        else if cell.value == -2
          errors.push {row: i, column: j, message: 'The cell is not illuminated'}
        else if cell.value >= 0
          lights = cell.adjacentCells().filter((adj_cell) -> adj_cell.value == -3 || adj_cell.value == -5)
          if lights.length != cell.value
            errors.push {row: i, column: j, message: 'The number of lights is not correct'}

    errors

  generate: (game, solution = false) ->
    super game, solution, Nikoli.AkariCell

    for cell in board.querySelectorAll('.empty')
      cell.addEventListener 'click', ((evenment) => @toggle evenment.target), false

    return

  illuminate: ->
    solution = @toArray()

    [].forEach.call @grid.querySelectorAll('.empty'), (cell) ->
      akari_cell = new Nikoli.AkariCell(parseInt(cell.dataset.row), parseInt(cell.dataset.column), solution)

      if akari_cell.isIlluminated()
        cell.classList.add('light')
      else
        cell.classList.remove('light')


  toggle: (cell) ->
    cell.classList.toggle 'black'
    @illuminate()

  toArray: ->
    [].map.call @grid.querySelectorAll('.grid-row'), (row) ->
      [].map.call row.querySelectorAll('.grid-cell'), (cell) ->
        if cell.classList.contains('empty')
          if cell.classList.contains('black') && cell.classList.contains('light')
            -5
          else if cell.classList.contains('light')
            -4
          else if cell.classList.contains('black')
            -3
          else
            -2
        else
          value = parseInt(cell.innerHTML)
          if isNaN(value) then -1 else value

class Nikoli.AkariCell extends Nikoli.Cell
  create: (value, solution = false) ->
    cell = super

    if value >= -1
      cell.classList.add 'white'
      cell.innerHTML = value if value >= 0
    else
      cell.classList.add 'empty'

      if solution
        if value == -3
          cell.classList.add 'black'
        else if value == -4
          cell.classList.add 'light'
        else if value == -5
          cell.classList.add 'black'
          cell.classList.add 'light'

    cell

  isIlluminated: ->
    @lightLeft() || @lightRight() || @lightUp() || @lightDown()

  light: (array) ->
    for value in array
      if value == -3 || value == -5
        return true
      else if value >= -1
        return false

    return false

  lightLeft: ->
    @y != 0 && @light(@getRow().slice(0, @y).reverse())

  lightRight: ->
    @y != (@getRow().length - 1) && @light(@getRow().slice(@y + 1))

  lightUp: ->
    @x != 0 && @light(@getColumn().slice(0, @x).reverse())

  lightDown: ->
    @x !=  (@getColumn().length - 1) && @light(@getColumn().slice(@x + 1))
