class Nikoli.Sudoku extends Nikoli.Game
  constructor: (@board, @name = 'sudoku') ->
    super @board, @name

  errors: ->
    solution = @toArray()
    errors = []

    for i in [0...solution.length]
      row = solution[i]
      for j in [0...row.length]
        cell = new Nikoli.Cell(i, j, solution)

        if cell.value == 0
          errors.push {row: i, column: j, message: 'The cell has no value.'}
        else if cell.rowDuplicates() || cell.columnDuplicates() || cell.squareDuplicates({x: Math.floor(i/3)*3, y: Math.floor(j/3)*3}, 3)
          errors.push {row: i, column: j, message: 'The number appears more than once in the row, column or square.'}

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

  toArray: (solution = false) ->
    [].map.call @grid.querySelectorAll('.grid-row'), (row) ->
      [].map.call row.querySelectorAll('.grid-cell'), (cell) ->
        if cell.classList.contains('empty')
          value = parseInt(cell.querySelector('input').value)
          if isNaN(value)
            0
          else
            if solution then -value else value
        else
          parseInt(cell.innerHTML)
