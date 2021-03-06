class Nikoli.Hitori extends Nikoli.Game
  constructor: (@board, @name = 'hitori', @url = null) ->
    super @board, @name, @url

  errors: ->
    solution = @toArray()
    errors = []
    processed_cells = []
    white_stream = new Nikoli.Stream(solution)

    for i in [0...solution.length]
      row = solution[i]
      for j in [0...row.length]
        cell = new Nikoli.HitoriCell(i, j, solution)

        if cell.value >= 0
          white_stream.calculate(cell) if white_stream.empty()

          if !white_stream.include(cell)
            errors.push {row: i, column: j, message: 'The stream must be continuous'}

          if cell.rowDuplicates() || cell.columnDuplicates()
            errors.push {row: i, column: j, message: 'The number appears more than once in the row or column.'}
        else
          if cell.adjacentCells().some((adj_cell) -> adj_cell.valid(-1))
            errors.push {row: i, column: j, message: 'Adjacent filled-in cells'}

    errors

  generate: (game, solution = false) ->
    super game, solution, Nikoli.HitoriCell

    for cell in board.querySelectorAll('.grid-cell')
      cell.addEventListener 'click', ((evenment) => @toggle evenment.target), false

    return

  toggle: (cell) ->
    if cell.classList.contains 'black'
      cell.classList.remove 'black'
      cell.classList.add 'white'
    else if cell.classList.contains 'white'
      cell.classList.remove 'white'
    else
      cell.classList.add 'black'

  toArray: ->
    [].map.call @grid.querySelectorAll('.grid-row'), (row) ->
      [].map.call row.querySelectorAll('.grid-cell'), (cell) ->
        if cell.classList.contains('black')
          -1
        else
          parseInt(cell.innerHTML)

class Nikoli.HitoriCell extends Nikoli.Cell
  create: (value) ->
    cell = super
    cell.innerHTML = value

    cell
