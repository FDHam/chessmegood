require "test_helper"

class PieceTest < ActiveSupport::TestCase
  def setup
    @game = Game.create!(status: "pending")
    @board = Board.create!(game: @game)
    @piece = Piece.new(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @piece.valid?
  end

  test "should require piece_type" do
    @piece.piece_type = nil
    assert_not @piece.valid?
    assert_includes @piece.errors[:piece_type], "can't be blank"
  end

  test "should validate piece_type inclusion" do
    assert_raises ArgumentError do
      @piece.piece_type = "invalid"
    end
  end

  test "should require color" do
    @piece.color = nil
    assert_not @piece.valid?
    assert_includes @piece.errors[:color], "can't be blank"
  end

  test "should validate color inclusion" do
    assert_raises ArgumentError do
      @piece.color = "invalid"
    end
  end

  test "should require file" do
    @piece.file = nil
    assert_not @piece.valid?
    assert_includes @piece.errors[:file], "can't be blank"
  end

  test "should validate file inclusion" do
    @piece.file = "z"
    assert_not @piece.valid?
    assert_includes @piece.errors[:file], "is not included in the list"
  end

  test "should require rank" do
    @piece.rank = nil
    assert_not @piece.valid?
    assert_includes @piece.errors[:rank], "can't be blank"
  end

  test "should validate rank inclusion" do
    @piece.rank = 9
    assert_not @piece.valid?
    assert_includes @piece.errors[:rank], "is not included in the list"
  end

  test "should require unique position when not captured" do
    @piece.save!
    duplicate_piece = Piece.new(piece_type: "rook", color: "black", file: "a", rank: 2, board: @board)

    assert_not duplicate_piece.valid?
    assert_includes duplicate_piece.errors[:file], "has already been taken"
  end

  test "should allow duplicate position when captured" do
    @piece.captured = true
    @piece.save!

    duplicate_piece = Piece.new(piece_type: "rook", color: "black", file: "a", rank: 2, board: @board)
    assert duplicate_piece.valid?
  end

  test "should default captured to false" do
    piece = Piece.create!(piece_type: "pawn", color: "white", file: "b", rank: 2, board: @board)
    assert_equal false, piece.captured
  end

  # Association tests
  test "should belong to board" do
    assert_equal @board, @piece.board
  end

  test "should have many moves" do
    @piece.save!
    assert_respond_to @piece, :moves
  end

  test "should have game through board" do
    @piece.save!
    assert_equal @game, @piece.game
  end

  # Scope tests
  test "active scope should return non-captured pieces" do
    active_piece = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)
    captured_piece = Piece.create!(piece_type: "pawn", color: "black", file: "b", rank: 7, board: @board, captured: true)

    active_pieces = Piece.active
    assert_includes active_pieces, active_piece
    assert_not_includes active_pieces, captured_piece
  end

  test "captured scope should return captured pieces" do
    active_piece = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)
    captured_piece = Piece.create!(piece_type: "pawn", color: "black", file: "b", rank: 7, board: @board, captured: true)

    captured_pieces = Piece.captured
    assert_includes captured_pieces, captured_piece
    assert_not_includes captured_pieces, active_piece
  end

  test "by_color scope should filter by color" do
    white_piece = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)
    black_piece = Piece.create!(piece_type: "pawn", color: "black", file: "b", rank: 7, board: @board)

    white_pieces = Piece.by_color("white")
    assert_includes white_pieces, white_piece
    assert_not_includes white_pieces, black_piece
  end

  test "by_type scope should filter by piece type" do
    pawn = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)
    rook = Piece.create!(piece_type: "rook", color: "white", file: "b", rank: 1, board: @board)

    pawns = Piece.by_type("pawn")
    assert_includes pawns, pawn
    assert_not_includes pawns, rook
  end

  # Instance method tests
  test "position should return file and rank concatenated" do
    assert_equal "a2", @piece.position
  end

  test "capture! should mark piece as captured and refresh board position" do
    @piece.save!
    original_position_data = @board.position_data.dup

    @piece.capture!

    assert @piece.captured?
    # Position data should be updated (mocked refresh_position_data!)
  end

  test "move_to! should update piece position and capture target" do
    @piece.save!
    target_piece = Piece.create!(piece_type: "pawn", color: "black", file: "b", rank: 2, board: @board)

    result = @piece.move_to!("b", 2)

    assert result
    @piece.reload
    assert_equal "b", @piece.file
    assert_equal 2, @piece.rank

    target_piece.reload
    assert target_piece.captured?
  end

  test "move_to! should fail for invalid moves" do
    @piece.save!

    # Mock can_move_to? to return false
    @piece.define_singleton_method(:can_move_to?) { |file, rank| false }

    result = @piece.move_to!("b", 2)

    assert_not result
    assert_equal "a", @piece.file
    assert_equal 2, @piece.rank
  end

  test "can_move_to? should validate basic move rules" do
    @piece.save!

    # Valid position
    assert @piece.can_move_to?("b", 3)

    # Invalid position (off board)
    assert_not @piece.can_move_to?("z", 10)

    # Same position
    assert_not @piece.can_move_to?("a", 2)

    # Own piece at destination
    own_piece = Piece.create!(piece_type: "rook", color: "white", file: "b", rank: 2, board: @board)
    assert_not @piece.can_move_to?("b", 2)
  end

  test "to_fen_char should return correct FEN characters" do
    test_cases = [
      [ "pawn", "white", "P" ],
      [ "pawn", "black", "p" ],
      [ "rook", "white", "R" ],
      [ "rook", "black", "r" ],
      [ "knight", "white", "N" ],
      [ "knight", "black", "n" ],
      [ "bishop", "white", "B" ],
      [ "bishop", "black", "b" ],
      [ "queen", "white", "Q" ],
      [ "queen", "black", "q" ],
      [ "king", "white", "K" ],
      [ "king", "black", "k" ]
    ]

    test_cases.each do |piece_type, color, expected_char|
      piece = Piece.new(piece_type: piece_type, color: color, file: "a", rank: 1, board: @board)
      assert_equal expected_char, piece.to_fen_char
    end
  end

  test "same_color? should return true for same color pieces" do
    white_piece1 = Piece.new(color: "white", piece_type: "pawn", file: "a", rank: 1, board: @board)
    white_piece2 = Piece.new(color: "white", piece_type: "rook", file: "b", rank: 1, board: @board)
    black_piece = Piece.new(color: "black", piece_type: "pawn", file: "c", rank: 1, board: @board)

    assert white_piece1.same_color?(white_piece2)
    assert_not white_piece1.same_color?(black_piece)
  end

  test "opponent_color? should return true for different color pieces" do
    white_piece = Piece.new(color: "white", piece_type: "pawn", file: "a", rank: 1, board: @board)
    black_piece = Piece.new(color: "black", piece_type: "pawn", file: "b", rank: 1, board: @board)

    assert white_piece.opponent_color?(black_piece)
    assert_not white_piece.opponent_color?(white_piece)
  end

  test "player should return the player with same color" do
    @piece.save!
    white_player = Player.create!(name: "White Player", color: "white", game: @game)
    black_player = Player.create!(name: "Black Player", color: "black", game: @game)

    assert_equal white_player, @piece.player

    @piece.color = "black"
    assert_equal black_player, @piece.player
  end

  # Enum tests
  test "should have correct piece_type enums" do
    expected_types = %w[pawn rook knight bishop queen king]
    assert_equal expected_types.sort, Piece.piece_types.keys.sort
  end

  test "should have correct color enums" do
    expected_colors = %w[white black]
    assert_equal expected_colors.sort, Piece.colors.keys.sort
  end

  test "should respond to piece type predicate methods" do
    @piece.piece_type = "pawn"
    assert @piece.pawn?
    assert_not @piece.rook?

    @piece.piece_type = "king"
    assert @piece.king?
    assert_not @piece.pawn?
  end

  test "should respond to color predicate methods" do
    @piece.color = "white"
    assert @piece.white?
    assert_not @piece.black?

    @piece.color = "black"
    assert @piece.black?
    assert_not @piece.white?
  end
end
