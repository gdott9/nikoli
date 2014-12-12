class Nikoli.Sudoku extends Nikoli.Game
  constructor: (@board, @name = 'sudoku') ->
    super @board, @name

  errors: ->
    solution = @toArray()
    errors = []

    for i in [0...solution.length]
      row = solution[i]
      for j in [0...row.length]
        cell = new Nikoli.SudokuCell(i, j, solution)

        if cell.value == 0
          errors.push {row: i, column: j, message: 'The cell has no value.'}
        else if cell.rowDuplicates() || cell.columnDuplicates() || cell.squareDuplicates({x: Math.floor(i/3)*3, y: Math.floor(j/3)*3}, 3)
          errors.push {row: i, column: j, message: 'The number appears more than once in the row, column or square.'}

    errors

  generate: (game, solution = false) ->
    super game, solution, Nikoli.SudokuCell

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

class Nikoli.SudokuCell extends Nikoli.Cell
  create: (value) ->
    cell = super
    if value <= 0
      cell.classList.add 'empty'
      cell.innerHTML = "<input type=\"text\" #{if value < 0 then "value=\"#{Math.abs(value)}\"" else ''} />"
    else
      cell.classList.add 'white'
      cell.innerHTML = value

    cell
