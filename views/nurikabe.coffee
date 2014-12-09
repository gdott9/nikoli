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
        cell = new Nikoli.Cell(i, j, solution)

        if cell.value < 0
          if black_stream.empty()
            black_stream.calculate(cell)
          else if !black_stream.include(cell)
            errors.push {row: i, column: j, message: 'The stream must be continuous'}
          # TODO check for pools
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
    @game = game if game?
    @grid.innerHTML = @game.map((row) ->
      '<div class="grid-row">' + row.map((cell) ->
        if cell <= 0
          color_class = 'black' if solution && cell == -1
          "<div class=\"grid-cell empty #{color_class}\">&nbsp;</div>"
        else
          "<div class=\"grid-cell white\">#{cell}</div>"
      ).join('') + '</div>'
    ).join('')

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
