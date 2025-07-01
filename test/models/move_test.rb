require "test_helper"

class MoveTest < ActiveSupport::TestCase
  def setup
    @game = Game.create!(status: "pending")
    @white_player = Player.create!(name: "White Player", color: "white", game: @game)
    @black_player = Player.create!(name: "Black Player", color: "black", game: @game)
    @board = Board.create!(game: @game)
    @piece = Piece.create!(piece_type: "pawn", color: "white", file: "e", rank: 2, board: @board)

    @game.update!(status: "active", current_player: @white_player)

    @move = Move.new(
      from_file: "e", from_rank: 2,
      to_file: "e", to_rank: 4,
      piece: @piece,
      player: @white_player,
      game: @game
    )
  end

  # Validation tests
  test "should be valid with valid attributes" do
    # Prevent callbacks for validation testing
    @move.define_singleton_method(:execute_move!) { true }
    assert @move.valid?
  end

  test "should require from_file" do
    @move.from_file = nil
    assert_not @move.valid?
    assert_includes @move.errors[:from_file], "can't be blank"
  end

  test "should validate from_file inclusion" do
    @move.from_file = "z"
    assert_not @move.valid?
    assert_includes @move.errors[:from_file], "is not included in the list"
  end

  test "should require to_file" do
    @move.to_file = nil
    assert_not @move.valid?
    assert_includes @move.errors[:to_file], "can't be blank"
  end

  test "should validate to_file inclusion" do
    @move.to_file = "z"
    assert_not @move.valid?
    assert_includes @move.errors[:to_file], "is not included in the list"
  end

  test "should require from_rank" do
    @move.from_rank = nil
    assert_not @move.valid?
    assert_includes @move.errors[:from_rank], "can't be blank"
  end

  test "should validate from_rank inclusion" do
    @move.from_rank = 9
    assert_not @move.valid?
    assert_includes @move.errors[:from_rank], "is not included in the list"
  end

  test "should require to_rank" do
    @move.to_rank = nil
    assert_not @move.valid?
    assert_includes @move.errors[:to_rank], "can't be blank"
  end

  test "should validate to_rank inclusion" do
    @move.to_rank = 9
    assert_not @move.valid?
    assert_includes @move.errors[:to_rank], "is not included in the list"
  end

  test "should validate algebraic_notation length" do
    @move.algebraic_notation = "a" * 11
    assert_not @move.valid?
    assert_includes @move.errors[:algebraic_notation], "is too long (maximum is 10 characters)"
  end

  test "should require different positions" do
    @move.from_file = "e"
    @move.from_rank = 2
    @move.to_file = "e"
    @move.to_rank = 2

    assert_not @move.valid?
    assert_includes @move.errors[:base], "Move must be to a different position"
  end

  test "should validate piece is at from position" do
    @move.from_file = "d" # Piece is at e2, not d2

    assert_not @move.valid?
    assert_includes @move.errors[:piece], "is not at the from position"
  end

  test "should validate player owns piece" do
    @move.player = @black_player # Black player trying to move white piece

    assert_not @move.valid?
    assert_includes @move.errors[:player], "does not own this piece"
  end

  test "should validate game is active" do
    @game.update!(status: "completed")

    assert_not @move.valid?
    assert_includes @move.errors[:game], "is not active"
  end

  test "should validate move is valid for piece" do
    # Mock piece.can_move_to? to return false
    @piece.define_singleton_method(:can_move_to?) { |file, rank| false }

    assert_not @move.valid?
    assert_includes @move.errors[:base], "is not a valid move for this piece"
  end

  # Association tests
  test "should belong to piece" do
    assert_equal @piece, @move.piece
  end

  test "should belong to player" do
    assert_equal @white_player, @move.player
  end

  test "should belong to game" do
    assert_equal @game, @move.game
  end

  test "should have board through game" do
    # Need to save move to test association
    @move.define_singleton_method(:execute_move!) { true }
    @move.save!
    assert_equal @board, @move.board
  end

  # Scope tests
  test "chronological scope should order by created_at" do
    @move.define_singleton_method(:execute_move!) { true }
    @move.save!

    # Create second move
    second_piece = Piece.create!(piece_type: "pawn", color: "black", file: "e", rank: 7, board: @board)
    @game.update!(current_player: @black_player)

    second_move = Move.new(
      from_file: "e", from_rank: 7,
      to_file: "e", to_rank: 5,
      piece: second_piece,
      player: @black_player,
      game: @game
    )
    second_move.define_singleton_method(:execute_move!) { true }
    second_move.save!

    moves = Move.chronological
    assert_equal @move, moves.first
    assert_equal second_move, moves.second
  end

  test "by_game scope should filter by game" do
    @move.define_singleton_method(:execute_move!) { true }
    @move.save!

    other_game = Game.create!(status: "pending")
    other_move = Move.create!(
      from_file: "a", from_rank: 1,
      to_file: "a", to_rank: 2,
      piece: @piece,
      player: @white_player,
      game: other_game
    )

    game_moves = Move.by_game(@game)
    assert_includes game_moves, @move
    assert_not_includes game_moves, other_move
  end

  test "by_player scope should filter by player" do
    @move.define_singleton_method(:execute_move!) { true }
    @move.save!

    black_move = Move.create!(
      from_file: "a", from_rank: 7,
      to_file: "a", to_rank: 6,
      piece: @piece,
      player: @black_player,
      game: @game
    )

    white_moves = Move.by_player(@white_player)
    assert_includes white_moves, @move
    assert_not_includes white_moves, black_move
  end

  # Instance method tests
  test "from_position should return from coordinates" do
    assert_equal "e2", @move.from_position
  end

  test "to_position should return to coordinates" do
    assert_equal "e4", @move.to_position
  end

  test "is_capture? should detect captures" do
    # No piece at destination
    assert_not @move.is_capture?

    # Add piece at destination
    target_piece = Piece.create!(piece_type: "pawn", color: "black", file: "e", rank: 4, board: @board)
    assert @move.is_capture?
  end

  test "is_castling? should detect castling moves" do
    king = Piece.create!(piece_type: "king", color: "white", file: "e", rank: 1, board: @board)

    # King side castling
    castling_move = Move.new(
      from_file: "e", from_rank: 1,
      to_file: "g", to_rank: 1,
      piece: king,
      player: @white_player,
      game: @game
    )
    assert castling_move.is_castling?

    # Queen side castling
    castling_move.to_file = "c"
    assert castling_move.is_castling?

    # Not castling
    assert_not @move.is_castling?
  end

  test "is_en_passant? should detect en passant moves" do
    # Regular pawn move
    assert_not @move.is_en_passant?

    # En passant move (pawn captures diagonally to empty square)
    en_passant_move = Move.new(
      from_file: "e", from_rank: 5,
      to_file: "f", to_rank: 6,
      piece: @piece,
      player: @white_player,
      game: @game
    )
    assert en_passant_move.is_en_passant?
  end

  test "to_s should return algebraic notation or coordinate notation" do
    @move.algebraic_notation = "e4"
    assert_equal "e4", @move.to_s

    @move.algebraic_notation = nil
    assert_equal "e2-e4", @move.to_s
  end

  # Callback tests
  test "should generate algebraic notation before validation" do
    @move.algebraic_notation = nil
    @move.define_singleton_method(:execute_move!) { true }
    @move.valid?

    assert_equal "e4", @move.algebraic_notation
  end

  test "should not overwrite existing algebraic notation" do
    @move.algebraic_notation = "custom"
    @move.define_singleton_method(:execute_move!) { true }
    @move.valid?

    assert_equal "custom", @move.algebraic_notation
  end

  test "should execute move after create" do
    # Mock the piece.move_to! method to track execution
    move_executed = false
    @piece.define_singleton_method(:move_to!) do |file, rank|
      move_executed = true
      true
    end

    @move.save!

    assert move_executed
  end

  # Algebraic notation generation tests
  test "should generate correct notation for pawn moves" do
    @move.algebraic_notation = nil
    @move.send(:generate_algebraic_notation)

    assert_equal "e4", @move.algebraic_notation
  end

  test "should generate correct notation for piece moves" do
    rook = Piece.create!(piece_type: "rook", color: "white", file: "a", rank: 1, board: @board)
    rook_move = Move.new(
      from_file: "a", from_rank: 1,
      to_file: "a", to_rank: 4,
      piece: rook,
      player: @white_player,
      game: @game
    )

    rook_move.send(:generate_algebraic_notation)
    assert_equal "Ra4", rook_move.algebraic_notation
  end

  test "should generate correct notation for captures" do
    # Add target piece
    target_piece = Piece.create!(piece_type: "pawn", color: "black", file: "f", rank: 3, board: @board)

    capture_move = Move.new(
      from_file: "e", from_rank: 2,
      to_file: "f", to_rank: 3,
      piece: @piece,
      player: @white_player,
      game: @game
    )

    capture_move.send(:generate_algebraic_notation)
    assert_equal "exf3", capture_move.algebraic_notation
  end

  test "should generate castling notation" do
    king = Piece.create!(piece_type: "king", color: "white", file: "e", rank: 1, board: @board)

    # King side castling
    castling_move = Move.new(
      from_file: "e", from_rank: 1,
      to_file: "g", to_rank: 1,
      piece: king,
      player: @white_player,
      game: @game
    )

    castling_move.send(:generate_algebraic_notation)
    assert_equal "O-O", castling_move.algebraic_notation

    # Queen side castling
    castling_move.to_file = "c"
    castling_move.send(:generate_algebraic_notation)
    assert_equal "O-O-O", castling_move.algebraic_notation
  end

  # Private method tests
  test "execute_move! should move piece and switch players" do
    original_player = @game.current_player

    # Mock piece.move_to! to return true
    @piece.define_singleton_method(:move_to!) { |file, rank| true }

    @move.send(:execute_move!)

    @game.reload
    assert_not_equal original_player, @game.current_player
  end

  test "execute_move! should not execute if move is invalid" do
    @move.from_file = "z" # Invalid
    original_player = @game.current_player

    @move.send(:execute_move!)

    @game.reload
    assert_equal original_player, @game.current_player
  end
end
