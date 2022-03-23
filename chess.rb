require 'pry-byebug'

class Game
  
  attr_accessor :board

  def create_board
    @lateral_margin = [1, 2, 3, 4, 5, 6, 7, 8]
    @board = []
    8.times { |i| @board[i] = Array.new(8, '□') }
    @bottom_margin = [' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  end

  def display_board
    @lateral_margin.reverse.zip(@board) do |num, row|
      print "#{num}|"
      row.each do |elem|
        if elem.is_a?(Piece)
          print "#{elem.symbol} "
        else
          print "#{elem} "
        end
      end
      print "\n"
    end
    puts "#{@bottom_margin.join(' ')}"
  end

  def index_of_piece_in_board(piece)
    @board.each_with_index do |row, row_index| 
      row.each_with_index do |board_piece, column_index| 
        if board_piece == piece 
          return [row_index, column_index]
        end
      end
    end
    raise StandardError.new('Piece not found')
  end

  def set_piece(piece, color, position = 'default')
    if position == 'default'
      if color == 'white'
        if piece.is_a?(Pawn)
          @board[6].each_with_index do |elem, index|
            if elem == '□'
              @board[6][index] = piece
              return
            end
          end
        end
        if piece.is_a?(Knight)
          if @board[7][1] == '□'
            @board[7][1] = piece
            return
          end
          @board[7][6] = piece
        end
        if piece.is_a?(Bishop)
          if @board[7][2] == '□'
            @board[7][2] = piece
            return
          end
          @board[7][5] = piece
        end
        if piece.is_a?(Rook)
          if @board[7][0] == '□'
            @board[7][0] = piece
            return
          end
          @board[7][7] = piece
        end
        @board[7][3] = piece if piece.is_a?(Queen)
        @board[7][4] = piece if piece.is_a?(King)
      else  
        if piece.is_a?(Pawn)
          @board[1].each_with_index do |elem, index|
            if elem == '□'
              @board[1][index] = piece
              return
            end
          end
        end
        if piece.is_a?(Knight)
          if @board[0][1] == '□'
            @board[0][1] = piece
            return
          end
          @board[0][6] = piece
        end
        if piece.is_a?(Bishop)
          if @board[0][2] == '□'
            @board[0][2] = piece
            return
          end
          @board[0][5] = piece
        end
        if piece.is_a?(Rook)
          if @board[0][0] == '□'
            @board[0][0] = piece
            return
          end
          @board[0][7] = piece
        end
        @board[0][3] = piece if piece.is_a?(Queen)
        @board[0][4] = piece if piece.is_a?(King)
      end
    end
  end

  def initialize_board
    @players.each do |player|
      player.pieces.each do |piece|
        set_piece(piece, piece.color)
      end
    end
  end

  def identify_square(string)
    string = string.split('')
    case string[0]
    when 'a'
      string[0] = 0
    when 'b'
      string[0] = 1
    when 'c'
      string[0] = 2
    when 'd'
      string[0] = 3
    when 'e'
      string[0] = 4
    when 'f'
      string[0] = 5
    when 'g'
      string[0] = 6
    when 'h'
      string[0] = 7
    end

    case string[1].to_i
    when 1
      string[1] = 7
    when 2
      string[1] = 6
    when 3
      string[1] = 5
    when 4
      string[1] = 4
    when 5
      string[1] = 3
    when 6
      string[1] = 2
    when 7
      string[1] = 1
    when 8
      string[1] = 0
    end

    return [@board[string[1]][string[0]], string[1], string[0]]
  end

  def start
    @players = []
    puts 'Please insert Player 1 name'
    name = gets.chomp
    @players.push(Player.new(name, 'white'))
    puts 'Please insert Player 2 name'
    name = gets.chomp
    @players.push(Player.new(name, 'black'))
    initialize_board
    display_board
    play
  end

  def play 
    @selected_piece = ask_for_piece_to_move
    @selected_piece = identify_square(@selected_piece)[0]
    @desired_location = ask_for_location
    @desired_location = [identify_square(@desired_location)[1], identify_square(@desired_location)[2]]
    @piece_position = index_of_piece_in_board(@selected_piece)
    until check_if_location_valid(@piece_position, @selected_piece)
      @desired_location = ask_for_location
      @desired_location = [identify_square(@desired_location)[1], identify_square(@desired_location)[2]]
    end
  end
  
  def ask_for_piece_to_move
    puts 'Please choose the piece you want to move'
    piece = gets.chomp.downcase
    
    until piece.match(/^[a-h][1-8]$/) && identify_square(piece) != '□'
      puts 'Please choose a valid location'
      piece = gets.chomp.downcase
    end
    return piece
  end
 
  def ask_for_location
    puts 'Please choose where you want to move the piece'
    location = gets.chomp.downcase
    until location.match(/^[a-h][1-8]$/)
      puts 'Please choose a valid location'
      location = gets.chomp.downcase
    end
    return location
  end

  def check_if_location_valid(location, piece)
    @possible_moves = piece.find_possible_moves(location, @board)
    if @possible_moves.empty?
      puts 'You can\'t move that piece anywhere. Please choose another one'
      play
    end
    if @possible_moves.include?(@desired_location)
      return true
    else
      puts 'You can\'t move there. Please choose a valid location'
      return false
    end
  end
     

end

class Player
  attr_reader :pieces, :color, :name
  attr_accessor :score

  def initialize(name, color)
    @pieces = []
    10.times do
      @pieces.push(Pawn.new(color, color == 'black' ? '♟' : '♙'))
    end
    2.times do
      @pieces.push(Knight.new(color, color == 'black' ? '♞' : '♘'))
    end
    2.times do
      @pieces.push(Bishop.new(color, color == 'black' ? '♝' : '♗'))
    end
    2.times do
      @pieces.push(Rook.new(color, color == 'black' ? '♜' : '♖'))
    end
    @pieces.push(Queen.new(color, color == 'black' ? '♛' : '♕'))
    @pieces.push(King.new(color, color == 'black' ? '♚' : '♔'))

    @name = name
    @color = color
    @score = 0
  end
end

class Piece
  attr_reader :color, :symbol, :move

  def initialize(color, symbol)
    @color = color
    @symbol = symbol
    @move = 0
  end
end

class Pawn < Piece

  def find_possible_moves(current_position, board)
    moves = []
    row = current_position[0]
    column = current_position[1]
   
    if self.color == 'black'
      moves.push([row + 1, column]) unless board[row + 1][column].is_a?(Piece) && !(row + 1).between?(0, 7) && !column.between?(0, 7)
      if self.move == 0 
        moves.push([row + 2, column]) unless board[row + 2][column].is_a?(Piece) && !(row + 2).between?(0, 7) && !column.between?(0, 7)
      end
      moves.push([row + 1, column + 1]) if board[row + 1][column + 1].is_a?(Piece) && (row + 1).between?(0, 7) && (column + 1).between?(0, 7)
      moves.push([row + 1, column - 1]) if board[row + 1][column - 1].is_a?(Piece) && (row + 1).between?(0, 7) && (column - 1).between?(0, 7)
      return moves
    else
      moves.push([row - 1, column]) unless board[row - 1][column].is_a?(Piece) && !(row - 1).between?(0, 7) && !column.between?(0, 7)
      if self.move == 0
        moves.push([row - 2, column]) unless board[row - 2][column].is_a?(Piece) && !(row - 2).between?(0, 7) && !column.between?(0, 7)
      end
      moves.push([row - 1, column - 1]) if board[row - 1][column - 1].is_a?(Piece) && (row - 1).between?(0, 7) && (column - 1).between?(0, 7)
      moves.push([row - 1, column + 1]) if board[row - 1][column + 1].is_a?(Piece) && (row - 1).between?(0, 7) && (column + 1).between?(0, 7)
      return moves 
    end
  end
end

class Knight < Piece
  def find_possible_moves(current_position, board)
    moves = []
    row = current_position[0]
    column = current_position[1]
    check_move(row - 2, column + 1, moves, board)
    check_move(row - 1, column + 2, moves, board)
    check_move(row + 1, column + 2, moves, board)
    check_move(row + 2, column + 1, moves, board)
    check_move(row + 2, column - 1, moves, board)
    check_move(row + 1, column - 2, moves, board)
    check_move(row - 1, column - 2, moves, board)
    check_move(row - 2, column - 1, moves, board)
    p moves 
    return moves
  end

  def check_move(row, column, moves, board)
    if row.between?(0, 7) && column.between?(0, 7)
      if !board[row][column].is_a?(Piece)
        moves.push([row, column])
      elsif board[row][column].color != self.color 
        moves.push([row, column])
      end
    end
  end

end

class Bishop < Piece
  def find_possible_moves(current_position, board)
    stop = false
    moves = []
    row = current_position[0]
    column = current_position[1]
    row_index = row - 1
    column_index = column + 1
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index -= 1
      column_index += 1
    end
    row_index = row - 1
    column_index = column - 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index -= 1
      column_index -= 1
    end
    row_index = row + 1
    column_index = column + 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index += 1
      column_index += 1
    end
    row_index = row + 1
    column_index = column - 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index += 1
      column_index -= 1
    end
    return moves
  end

  def check_move(row, column, moves, board, stop)
    if !board[row][column].is_a?(Piece)
      moves.push([row, column])
    elsif board[row][column].color == self.color
      stop = true
    else
      moves.push([row_index, column_index])
      stop = true
    end
    return stop 
  end
end

class King < Piece
  def find_possible_moves(current_position, board)
    moves = []
    row = current_position[0]
    column = current_position[1]
    check_move(row, column - 1, moves, board)
    check_move(row - 1, column - 1, moves, board)
    check_move(row - 1, column, moves, board)
    check_move(row - 1, column + 1, moves, board)
    check_move(row + 1, column + 1, moves, board)
    check_move(row + 1, column, moves, board)
    check_move(row + 1, column - 1, moves, board)
    check_move(row, column + 1, moves, board)
    return moves
  end

  def check_move(row, column, moves, board)
    if row.between?(0, 7) && column.between?(0, 7)
      if board[row][column].is_a?(Piece)
        if board[row][column].color != self.color 
          moves.push([row, column])
        end
      else
        moves.push([row, column])
      end
    end
  end
end

class Queen < Piece
  def find_possible_moves(current_position, board)
    stop = false
    moves = []
    row = current_position[0]
    column = current_position[1]
    row_index = row
    column_index = column + 1
    while column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      column_index += 1
    end
    column_index = column - 1
    stop = false
    while column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      column_index -= 1
    end
    column_index = column 
    row_index = row - 1
    stop = false
    while row_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index -= 1
    end
    row_index = row + 1
    stop = false
    while row_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index += 1
    end
    row_index = row - 1
    column_index = column + 1
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index -= 1
      column_index += 1
    end
    row_index = row - 1
    column_index = column - 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index -= 1
      column_index -= 1
    end
    row_index = row + 1
    column_index = column + 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index += 1
      column_index += 1
    end
    row_index = row + 1
    column_index = column - 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index += 1
      column_index -= 1
    end
    return moves
  end
   
  def check_move(row, column, moves, board, stop)
    if board[row][column].is_a?(Piece) 
      if board[row][column].color != self.color
        moves.push([row, column])
        stop = true
      else
        stop = true
      end
    else
      moves.push([row, column])
    end
    return stop
  end
end

class Rook < Piece
  def find_possible_moves(current_position, board)
    stop = false
    moves = []
    row = current_position[0]
    column = current_position[1]
    row_index = row
    column_index = column + 1
    while column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      column_index += 1
    end
    column_index = column - 1
    stop = false
    while column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      column_index -= 1
    end
    column_index = column 
    row_index = row - 1
    stop = false
    while row_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index -= 1
    end
    row_index = row + 1
    stop = false
    while row_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board, stop)
      row_index += 1
    end
    return moves
  end

  def check_move(row, column, moves, board, stop)
    if board[row][column].is_a?(Piece) 
      if board[row][column].color != self.color
        moves.push([row, column])
        stop = true
      else
        stop = true
      end
    else
      moves.push([row, column])
    end
    return stop
  end
end

game = Game.new
game.create_board
game.display_board
game.start
