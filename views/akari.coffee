class Nikoli.Akari extends Nikoli.Game
  constructor: (@board, @name = 'akari') ->
    super @board, @name

  errors: ->
    solution = @toArray()
    errors = []

    for i in [0...solution.length]
      row = solution[i]
      for j in [0...row.length]
        cell = new Nikoli.Cell(i, j, solution)

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
    @game = game if game?
    @grid.innerHTML = @game.map((row, i) ->
      '<div class="grid-row">' + row.map((cell, j) ->
        data = "data-row=\"#{i}\" data-column=\"#{j}\""
        if cell <= -2
          if solution
            color_class = if cell == -3
              'black'
            else if cell == -4
              'light'
            else if cell == -5
              'black light'
          "<div class=\"grid-cell empty #{color_class}\" #{data}>&nbsp;</div>"
        else
          "<div class=\"grid-cell white\" #{data}>#{if cell >= 0 then cell else '&nbsp;'}</div>"
      ).join('') + '</div>'
    ).join('')

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
