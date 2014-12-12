class Nikoli.Nurikabe extends Nikoli.Game
  constructor: (@board, @name = 'nurikabe') ->
    super @board, @name

  errors: ->
    solution = @toArray()
    errors = []
    black_stream = new Nikoli.Stream(solution)
    white_walls = []

    for i in [0...solution.length]
      row = solution[i]
      for j in [0...row.length]
        cell = new Nikoli.NurikabeCell(i, j, solution)

        if cell.value < 0
          if black_stream.empty()
            black_stream.calculate(cell)
          else if !black_stream.include(cell)
            errors.push {row: i, column: j, message: 'The stream must be continuous'}

          if cell.isPool()
            errors.push {row: i, column: j, message: 'There must be no pools.'}
        else if cell.value > 0
          if white_walls.some((wall) -> wall.include(cell))
            errors.push {row: i, column: j, message: 'Each wall must contain exactly one numbered cell.'}
          else
            wall = new Nikoli.Stream(solution)
            wall.calculate(cell)

            if wall.length() != cell.value
              errors.push {row: i, column: j, message: 'Each numbered cell is a wall cell, the number in it is the number of cells in that wall.'}

            white_walls.push(wall)

    errors

  generate: (game, solution = false) ->
    super game, solution, Nikoli.NurikabeCell

    for cell in board.querySelectorAll('.empty')
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
        if cell.classList.contains('empty')
          if cell.classList.contains('black')
            -1
          else
            0
        else
          parseInt(cell.innerHTML)

class Nikoli.NurikabeCell extends Nikoli.Cell
  create: (value, solution = false) ->
    cell = super

    if value <= 0
      cell.classList.add 'empty'
      cell.classList.add 'black' if solution && value == -1
    else
      cell.classList.add 'white'
      cell.innerHTML = value

    cell

  isPool: ->
    [
      new NurikabeCell(@x, @y + 1, @game),
      new NurikabeCell(@x + 1, @y, @game),
      new NurikabeCell(@x + 1, @y + 1, @game),
    ].every (cell) => cell.valid(@value)

