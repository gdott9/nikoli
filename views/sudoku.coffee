class Nikoli.Sudoku extends Nikoli.Game
  constructor: (@board, @name = 'sudoku') ->
    super @board, @name

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
