class Board
  attr_reader :cells

  def initialize(rows = 4, columns = 4)
    @number_range = number_range(columns)
    @letter_range = letter_range(rows)
    @cells = cell_generator(rows, columns)
  end

  def number_range(columns)
    ("1".."#{columns}").to_a
  end
  
  def letter_range(rows)
    ("A".."#{(64+rows).chr}").to_a
  end

  def cell_generator(rows, columns)
    numbers = @number_range * @letter_range.length
    letters = (@letter_range * @number_range.length).sort
    combos = letters.zip(numbers)
    coordinates = combos.map { |combo| combo.join }
    generated_cells = coordinates.each_with_object({}) do |coordinate, generated_cells|
      generated_cells[coordinate] = Cell.new(coordinate)
    end
    generated_cells
  end

  def valid_coordinate?(coordinate)
    @cells.keys.include?(coordinate)
  end

  def all_valid_coordinates?(coordinates)
    coordinates.all? { |coordinate| valid_coordinate?(coordinate) }
  end

  def valid_placement?(ship, coordinates)
    all_valid_coordinates?(coordinates) &&
    all_unoccupied?(coordinates) &&
    length_match?(ship, coordinates) && 
    consecutive?(coordinates) && 
    not_diagonal?(coordinates)
  end

  def length_match?(ship, coordinates)
    ship.length == coordinates.length
  end

  def consecutive?(coordinates)
    ordinal_values = []
    coordinates.each do |coordinate|
      ordinal_values << coordinate[0].ord + coordinate[1..2].to_i
    end
    ordinal_values.each_cons(2).all? { |first_num, next_num| first_num + 1 == next_num }
  end

  def not_diagonal?(coordinates)
    row_letter = coordinates.first[0]
    column_number = coordinates.first[1..2]
    coordinates.all? { |coordinate| coordinate[0] == row_letter } ||
    coordinates.all? { |coordinate| coordinate[1..2] == column_number }
  end
  
  def unoccupied?(coordinate)
    @cells[coordinate].empty?
  end

  def all_unoccupied?(coordinates)
    coordinates.all? do |coordinate|
      unoccupied?(coordinate)
    end
  end

  def place(ship, coordinates)
    if valid_placement?(ship, coordinates)
      coordinates.each do |coordinate|
        @cells[coordinate].place_ship(ship)
      end
    end
  end

  def render(show_ships = false)
    cell_rows = []
    @letter_range.each do |letter|
      cell_rows << render_cell_row(letter, show_ships)
    end
    full_board_array = cell_rows.unshift(render_number_row)
    full_board_array.join("")
  end

  def render_number_row
    numbers = @number_range
    numbers = numbers.append("\n").unshift(" ") unless numbers[0] == " "
    numbers.join(" ")
  end

  def render_cell_row(letter, show_ships = false)
    grouped = @cells.values.group_by { |cell| cell.coordinate.chr }
    rendered_cells = grouped[letter].map { |cell| cell.render(show_ships) }
    full_line_characters = rendered_cells.unshift("#{letter}").append("\n")
    full_line_characters.join(" ")
  end
end
