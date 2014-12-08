window.Sudoku = class Sudoku
  constructor: (@board) ->
    @board.classList.add 'sudoku'

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

    for i in [0..8]
      square = []
      column = []
      row = solution[i]

      for j in [0..8]
        column.push(solution[j][i])
        square.push(solution[(Math.floor(i/3)*3) + Math.floor(j/3)][(i%3*3) + (j%3)])

      console.log square
      console.log column
      ###
      # check square [i%3*3][j/3*3]
      # check row [i][.]
      # check column [.][i]
      ###

    errors

  generate: (game, solution = false) ->
    @game = game if game?
    @grid.innerHTML = @game.map((row) ->
      '<div class="grid-row">' + row.map((cell) ->
        if cell <= 0
          "<div class=\"grid-cell empty\"><input type=\"text\" #{if cell < 0 then "value=\"#{Math.abs(cell)}\""} /></div>"
        else
          "<div class=\"grid-cell white\">#{cell}</div>"
      ).join('') + '</div>'
    ).join('')

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
          -parseInt(cell.querySelector('input').value)
        else
          parseInt(cell.innerHTML)
