class Game 

  def initialize
  end

	def create_board
		@board = []
		9.times { |i| @board[i] = Array.new(9, '_') }
		j = 8
		for i in 0..7
			@board[i][0] = j 
			j -= 1
		end
		@board[8][0] = ' '
		@board[8][1] = 'A'
		@board[8][2] = 'B'
		@board[8][3] = 'C'
		@board[8][4] = 'D'
		@board[8][5] = 'E'
		@board[8][6] = 'F'
		@board[8][7] = 'G'
		@board[8][8] = 'H'
	end

	def display_board
		@board.each do |row|
			puts "#{row.join('|')}| \n"
		end
	end
	
	def set_piece(piece, position = "default") 
		if position == "default" 
			if piece.class == Pawn 
				 @board[1][0] = piece
			end
		end

	end

	def initialize_board()
		if @players.length < 2 
			# At least 2 players required to play the game
		end

		for player in @players 
			for piece in player.pieces 
				set_piece(piece)
			end
		end
	end

	def start 
		#ask for name + color Player 1
		#ask for name + color Player 2
		@players = [Player.new("Mihai", "white"), Player.new("Ana", "black")]
		initialize_board
		display_board
	end
end

class Player

	def initialize(name, color)
		@pieces = []
		10.times do 
			@pieces.push(Pawn.new(color))
		end
		2.times do 
			@pieces.push(Knight.new(color))
		end
		2.times do 
			@pieces.push()
		end

		@name = name
		@color = color
		@score = 0
	end


end

class Piece
	def initialize(color)
		@color = color
	end
end

class Pawn < Piece
end

class Knight < Piece
end

class Bishop < Piece
end

class King < Piece 
end

class Queen < Piece 
end

class Rook < Piece
end



game = Game.new
game.start()