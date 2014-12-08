window.Hitori = class Nurikabe
  constructor: (@board) ->
    @board.classList.add 'hitori'

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
    white_stream = new Nikoli.Stream(solution)

    for i in [0...solution.length]
      row = solution[i]
      for j in [0...row.length]
        cell = solution[i][j]

        if cell >= 0
          white_stream.calculate({x: i, y: j}) if white_stream.empty()

          if !white_stream.include({x: i, y: j})
            errors.push {row: i, column: j, message: 'The stream must be continuous'}
          # TODO check for duplicates in rows and columns
        else
          adjacent_cells = [
            {x: i+1, y: j},
            {x: i-1, y: j},
            {x: i, y: j+1},
            {x: i, y: j-1}
          ]
          if adjacent_cells.some((el) ->
            0 <= el.x < solution.length && 0 <= el.y < solution[el.x].length && solution[el.x][el.y] == -1)
            errors.push {row: i, column: j, message: 'Adjacent filled-in cells'}

    errors

  generate: (game, solution = false) ->
    @game = game if game?
    @grid.innerHTML = @game.map((row) ->
      '<div class="grid-row">' + row.map((cell) ->
        "<div class=\"grid-cell\">#{cell}</div>"
      ).join('') + '</div>'
    ).join('')

    for cell in board.querySelectorAll('.grid-cell')
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
        if cell.classList.contains('black')
          -1
        else
          parseInt(cell.innerHTML)
