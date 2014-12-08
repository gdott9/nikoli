window.Nurikabe = class Nurikabe
  constructor: (@board) ->
    @grid = document.createElement 'div'
    @grid.classList.add 'game-container'
    @board.appendChild @grid

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

  check: ->
    errors = @errors()

    if errors.length == 0
      alert 'Congratulations!'
    else
      alert errors.map((el) -> el.message).join()

  errors: ->
    solution = @toArray()
    errors = []
    processed_cells = []
    black_stream = new Nikoli.Stream(solution)
    white_walls = []

    for i in [0...solution.length]
      row = solution[i]
      for j in [0...row.length]
        cell = solution[i][j]

        if cell < 0
          if black_stream.empty()
            black_stream.calculate({x: i, y: j})
          else if !black_stream.include({x: i, y: j})
            errors.push {row: i, column: j, message: 'The stream must be continuous'}
        else if cell > 0
          if white_walls.some((wall) -> wall.include({x: i, y: j}))
            errors.push {row: i, column: j, message: 'Each wall must contain exactly one numbered cell.'}
          else
            wall = new Nikoli.Stream(solution)
            wall.calculate({x: i, y: j})

            if wall.length() != cell
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

  reset: ->
    @generate()

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
