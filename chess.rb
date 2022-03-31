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
    puts @bottom_margin.join(' ').to_s
  end

  def clone_of(board)
    new_board = []
    8.times { |i| new_board[i] = Array.new(8, '□') }
    board.each_with_index do |row, row_index|
      row.each_with_index do |_column, column_index|
        new_board[row_index][column_index] = board[row_index][column_index].clone
      end
    end
    new_board
  end

  def index_of_piece_in_board(piece, board = @board)
    board.each_with_index do |row, row_index|
      row.each_with_index do |_column, column_index|
        return [row_index, column_index] if board[row_index][column_index] == piece
      end
    end
    raise StandardError, 'Piece not found'
  end

  def set_piece(piece, color)
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

    [string[1], string[0]]
  end

  def start
    @order = 0
    @players = []
    puts 'Please insert Player 1 name'
    name = gets.chomp
    @players.push(Player.new(name, 'white'))
    puts 'Please insert Player 2 name'
    name = gets.chomp
    @players.push(Player.new(name, 'black'))
    create_board
    initialize_board
    move_piece(identify_square('e2'), identify_square('e4'), @players[0], @players[1])
    move_piece(identify_square('e7'), identify_square('e5'), @players[0], @players[1])
    move_piece(identify_square('d1'), identify_square('h5'), @players[0], @players[1])
    move_piece(identify_square('e8'), identify_square('e7'), @players[0], @players[1])
    display_board
    play
  end

  def play(order = 0)
    loop do
      player_start_input = ask_for_piece_to_move(order)
      @piece_position = identify_square(player_start_input)
      @selected_piece = @board[@piece_position[0]][@piece_position[1]]
      current_player = @players[order]
      other_player = @players[order == 0 ? 1 : 0]
      until @selected_piece.color == current_player.color
        puts "That is not your piece. Please choose a #{current_player.color} piece"
        play(order)
      end
      player_destination_input = ask_for_location
      @desired_location = identify_square(player_destination_input)
      until can_move_piece(current_player, other_player, @selected_piece, @piece_position, @desired_location)
        play(order)
      end
      move_piece(@piece_position, @desired_location, current_player, other_player)
      display_board
      puts "#{other_player.name} is in check!" if check_if_check(current_player, other_player)
      if order == 0
        order += 1
      else
        order -= 1
      end
      current_player = @players[order]
      other_player = @players[order == 0 ? 1 : 0]
      next unless current_player.check == true

      next unless check_if_check_mate(current_player, other_player, order)

      puts "Check-mate! #{current_player.name} lost."
      ask_if_play_again
      break
    end
  end

  def ask_if_play_again
    puts 'Do you wanna play again? Y/N'
    answer = gets.chomp.downcase
    until %w[y n].include?(answer)
      puts 'You must answer with y or n.'
      answer = gets.chomp.downcase
    end
    if answer == 'y'
      start
    else
      puts 'Okay. Bye-bye!'
    end
  end

  def can_move_piece(player, other_player, piece, initial_location, desired_location, board = @board, puts_message = true)
    possible_moves = piece.find_possible_moves(initial_location, board)
    if possible_moves.empty?
      puts 'You can\'t move that piece anywhere. Please choose another one'
      return false
    elsif possible_moves.include?(desired_location)
      hypothetical_board = clone_of(board)
      hypothetical_player = Player.new('', player.color, hypothetical_board)
      piece_clone = hypothetical_board[initial_location[0]][initial_location[1]]
      other_player_clone = Player.new('', other_player.color, hypothetical_board)
      hypothetical_player.check = false
      move_piece(initial_location, desired_location, hypothetical_player, other_player_clone, hypothetical_board)
      if check_if_check(other_player_clone, hypothetical_player, hypothetical_board)
        if player.check == true
          puts 'You can\'t move there. You are in check.' if puts_message == true        
        else
          puts 'You can\'t move there. You will be in check.' if puts_message == true 
        end
        return false
      end
      return true
    else
      puts 'You can\'t move there. Please choose a valid location'
      return false
    end
  end

  def check_if_check(player, other_player, board = @board)
    player.pieces.each do |piece|
      location = index_of_piece_in_board(piece, board)
      possible_moves = piece.find_possible_moves(location, board)
      possible_moves.each do |move|
        next unless board[move[0]][move[1]].is_a?(King)

        if board[move[0]][move[1]].color != player.color
          other_player.check = true
          return true
        end
      end
    end
    player.check = false
    return false
  end

  def check_if_check_mate(player, previous_player, _order, board = @board)
    player.pieces.each do |piece|
      location = index_of_piece_in_board(piece, board)
      possible_moves = piece.find_possible_moves(location, board)
      possible_moves.each do |move|
        hypothetical_board = clone_of(board)
        hypothetical_player = Player.new('', player.color, hypothetical_board)
        piece_clone = hypothetical_board[location[0]][location[1]]
        previous_player_clone = Player.new('', previous_player.color, hypothetical_board)
        if can_move_piece(hypothetical_player, previous_player_clone, piece_clone, location, move, hypothetical_board, false)
          move_piece(location, move, hypothetical_player, previous_player_clone, hypothetical_board)
          return false unless check_if_check(previous_player_clone, hypothetical_player, hypothetical_board)
        end
      end
    end
    true
  end

  def move_piece(inital_square, next_square, player, other_player, board = @board)
    initial_row = inital_square[0]
    initial_column = inital_square[1]
    next_row = next_square[0]
    next_column = next_square[1]
    other_player.pieces = other_player.pieces - [board[next_row][next_column]] if board[next_row][next_column].is_a?(Piece)
    board[initial_row][initial_column].did_move_once = true
    if board[initial_row][initial_column].is_a?(Pawn)
      if player.color == 'black' && next_row == 7
        board[next_row][next_column] = Queen.new(player.color, player.color == 'black' ? '♛' : '♕')
        player.pieces.push(board[next_row][next_column])
        player.pieces = player.pieces - [board[initial_row][initial_column]]
      elsif player.color == 'white' && next_row == 0
        board[next_row][next_column] = Queen.new(player.color, player.color == 'black' ? '♛' : '♕')
        player.pieces.push(board[next_row][next_column])
        player.pieces = player.pieces - [board[initial_row][initial_column]]
      else
        board[next_row][next_column] = board[initial_row][initial_column]
      end
    else
      board[next_row][next_column] = board[initial_row][initial_column]
    end
    board[initial_row][initial_column] = '□'
  end

  def ask_for_piece_to_move(order)
    puts "#{@players[order].name}, please choose the piece you want to move"
    player_start_input = gets.chomp.downcase
    indices = identify_square(player_start_input)
    until player_start_input.match(/^[a-h][1-8]$/) && @board[indices[0]][indices[1]] != '□'
      puts 'Please choose a location which has a valid piece'
      player_start_input = gets.chomp.downcase
    end
    player_start_input
  end

  def ask_for_location
    puts 'Please choose where you want to move the piece'
    location = gets.chomp.downcase
    until location.match(/^[a-h][1-8]$/)
      puts 'Please choose a valid location'
      location = gets.chomp.downcase
    end
    location
  end
end

class Player
  attr_reader :color, :name
  attr_accessor :score, :check, :check_mate, :pieces

  def initialize(name, color, board = nil)
    @pieces = []
    if board.nil?
      8.times do
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
    else
      board.each_with_index do |row, _row_index|
        row.each_with_index do |column, _column_index|
          @pieces.push(column) if column.is_a?(Piece) && column.color == color
        end
      end
    end
    @name = name
    @color = color
    @score = 0
    @check = false
  end
end

class Piece
  attr_reader :color, :symbol
  attr_accessor :did_move_once

  def initialize(color, symbol)
    @color = color
    @symbol = symbol
    @did_move_once = false
  end

  def is_king?(location)
    location.is_a?(King) ? true : false
  end

  def check_move(row, column, moves, board)
    if board[row][column].is_a?(Piece)
      if board[row][column].color != color
        moves.push([row, column])
        return true
      else
        return true
      end
    else
      moves.push([row, column])
    end
    return false
  end
end

class Pawn < Piece
  def find_possible_moves(current_position, board)
    moves = []
    row = current_position[0]
    column = current_position[1]

    if color == 'black'
      moves.push([row + 1, column]) if !board[row + 1][column].is_a?(Piece) && (row + 1).between?(0, 7) && column.between?(0, 7)
      if did_move_once == false && !board[row + 2][column].is_a?(Piece) && (row + 2).between?(0, 7) && column.between?(0, 7) 
        moves.push([row + 2, column])
      end
      if board[row + 1][column + 1].is_a?(Piece) && (row + 1).between?(0, 7) && (column + 1).between?(0, 7) && (board[row + 1][column + 1].color == 'white')
        moves.push([row + 1, column + 1])
      end
      if board[row + 1][column - 1].is_a?(Piece) && (row + 1).between?(0, 7) && (column - 1).between?(0, 7) && (board[row + 1][column - 1].color == 'white')
        moves.push([row + 1, column - 1])
      end
      moves
    else
      moves.push([row - 1, column]) if !board[row - 1][column].is_a?(Piece) && (row - 1).between?(0, 7) && column.between?(0, 7)
      if did_move_once == false && !board[row - 2][column].is_a?(Piece) && (row - 2).between?(0, 7) && column.between?(0, 7) 
        moves.push([row - 2, column])
      end
      if board[row - 1][column - 1].is_a?(Piece) && (row - 1).between?(0, 7) && (column - 1).between?(0, 7) && (board[row - 1][column - 1].color == 'black')
        moves.push([row - 1, column - 1])
      end
      if board[row - 1][column + 1].is_a?(Piece) && (row - 1).between?(0, 7) && (column + 1).between?(0, 7) && (board[row - 1][column + 1].color == 'black')
        moves.push([row - 1, column + 1])
      end
      moves
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
    moves
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
      stop = check_move(row_index, column_index, moves, board)
      row_index -= 1
      column_index += 1
    end
    row_index = row - 1
    column_index = column - 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index -= 1
      column_index -= 1
    end
    row_index = row + 1
    column_index = column + 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index += 1
      column_index += 1
    end
    row_index = row + 1
    column_index = column - 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index += 1
      column_index -= 1
    end
    moves
  end

  def check_move(row, column, moves, board)
    if board[row][column].is_a?(Piece)
      if board[row][column].color != self.color
        moves.push([row, column])
        return true
      else
        return true
      end
    else
      moves.push([row, column])
    end
    return false
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
    moves
  end

  def check_move(row, column, moves, board)
    if row.between?(0, 7) && column.between?(0, 7)
      if board[row][column].is_a?(Piece)
        moves.push([row, column]) if board[row][column].color != self.color
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
      stop = check_move(row_index, column_index, moves, board)
      column_index += 1
    end
    column_index = column - 1
    stop = false
    while column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      column_index -= 1
    end
    column_index = column
    row_index = row - 1
    stop = false
    while row_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index -= 1
    end
    row_index = row + 1
    stop = false
    while row_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index += 1
    end
    row_index = row - 1
    column_index = column + 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index -= 1
      column_index += 1
    end
    row_index = row - 1
    column_index = column - 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index -= 1
      column_index -= 1
    end
    row_index = row + 1
    column_index = column + 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index += 1
      column_index += 1
    end
    row_index = row + 1
    column_index = column - 1
    stop = false
    while row_index.between?(0, 7) && column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index += 1
      column_index -= 1
    end
    moves
  end

  def check_move(row, column, moves, board)
    if board[row][column].is_a?(Piece)
      if board[row][column].color != self.color
        moves.push([row, column])
        return true
      else
        return true
      end
    else
      moves.push([row, column])
    end
    return false
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
      stop = check_move(row_index, column_index, moves, board)
      column_index += 1
    end
    column_index = column - 1
    stop = false
    while column_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      column_index -= 1
    end
    column_index = column
    row_index = row - 1
    stop = false
    while row_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index -= 1
    end
    row_index = row + 1
    stop = false
    while row_index.between?(0, 7) && stop == false
      stop = check_move(row_index, column_index, moves, board)
      row_index += 1
    end
    moves
  end
end

game = Game.new
game.create_board
game.start
