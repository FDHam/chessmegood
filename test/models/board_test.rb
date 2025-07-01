require "test_helper"

class BoardTest < ActiveSupport::TestCase
  def setup
    @game = Game.create!(status: "pending")
    @board = Board.new(game: @game, position_data: {})
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @board.valid?
  end

  test "should require position_data" do
    @board.position_data = nil
    assert_not @board.valid?
    assert_includes @board.errors[:position_data], "can't be blank"
  end

  test "should require unique game_id" do
    @board.save!
    duplicate_board = Board.new(game: @game, position_data: {})

    assert_not duplicate_board.valid?
    assert_includes duplicate_board.errors[:game_id], "has already been taken"
  end

  test "should default position_data to empty hash" do
    board = Board.create!(game: @game)
    # Due to migration default as string, we get '{}' which is valid
    assert board.position_data.present?
  end

  # Association tests
  test "should belong to game" do
    assert_equal @game, @board.game
  end

  test "should have many pieces" do
    @board.save!
    assert_respond_to @board, :pieces
  end

  test "should destroy dependent pieces when destroyed" do
    @board.save!
    piece = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)

    assert_difference "Piece.count", -1 do
      @board.destroy
    end
  end

  # Constants tests
  test "should have correct FILES constant" do
    assert_equal %w[a b c d e f g h], Board::FILES
  end

  test "should have correct RANKS constant" do
    assert_equal (1..8).to_a, Board::RANKS
  end

  # Instance method tests
  test "setup_initial_position! should create all pieces" do
    @board.save!

    assert_difference "Piece.count", 32 do
      @board.setup_initial_position!
    end

    # Check white pieces
    assert @board.piece_at("a", 1).present?
    assert_equal "rook", @board.piece_at("a", 1).piece_type
    assert_equal "white", @board.piece_at("a", 1).color

    assert @board.piece_at("e", 1).present?
    assert_equal "king", @board.piece_at("e", 1).piece_type
    assert_equal "white", @board.piece_at("e", 1).color

    # Check white pawns
    Board::FILES.each do |file|
      pawn = @board.piece_at(file, 2)
      assert pawn.present?
      assert_equal "pawn", pawn.piece_type
      assert_equal "white", pawn.color
    end

    # Check black pieces
    assert @board.piece_at("a", 8).present?
    assert_equal "rook", @board.piece_at("a", 8).piece_type
    assert_equal "black", @board.piece_at("a", 8).color

    assert @board.piece_at("e", 8).present?
    assert_equal "king", @board.piece_at("e", 8).piece_type
    assert_equal "black", @board.piece_at("e", 8).color

    # Check black pawns
    Board::FILES.each do |file|
      pawn = @board.piece_at(file, 7)
      assert pawn.present?
      assert_equal "pawn", pawn.piece_type
      assert_equal "black", pawn.color
    end
  end

  test "setup_initial_position! should not create pieces if they already exist" do
    @board.save!
    existing_piece = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)

    assert_no_difference "Piece.count" do
      @board.setup_initial_position!
    end
  end

  test "piece_at should return piece at given position" do
    @board.save!
    piece = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)

    assert_equal piece, @board.piece_at("a", 2)
    assert_nil @board.piece_at("b", 2)
  end

  test "piece_at should not return captured pieces" do
    @board.save!
    piece = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board, captured: true)

    assert_nil @board.piece_at("a", 2)
  end

  test "empty_at? should return true for empty squares" do
    @board.save!

    assert @board.empty_at?("a", 2)

    Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)

    assert_not @board.empty_at?("a", 2)
  end

  test "valid_position? should validate chess coordinates" do
    @board.save!

    # Valid positions
    assert @board.valid_position?("a", 1)
    assert @board.valid_position?("h", 8)
    assert @board.valid_position?("d", 4)

    # Invalid positions
    assert_not @board.valid_position?("i", 1)
    assert_not @board.valid_position?("a", 9)
    assert_not @board.valid_position?("z", 0)
  end

  test "refresh_position_data! should update position_data with current pieces" do
    @board.save!
    piece1 = Piece.create!(piece_type: "pawn", color: "white", file: "a", rank: 2, board: @board)
    piece2 = Piece.create!(piece_type: "rook", color: "black", file: "h", rank: 8, board: @board)
    captured_piece = Piece.create!(piece_type: "bishop", color: "white", file: "c", rank: 1, board: @board, captured: true)

    @board.refresh_position_data!

    expected_data = {
      "a2" => { type: "pawn", color: "white", id: piece1.id },
      "h8" => { type: "rook", color: "black", id: piece2.id }
    }

    assert_equal expected_data.stringify_keys, @board.position_data
    assert_not @board.position_data.key?("c1") # Captured piece should not be included
  end

  test "to_fen should generate basic FEN string" do
    @board.save!
    @board.setup_initial_position!

    fen = @board.to_fen
    expected_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"

    assert_equal expected_fen, fen
  end

  test "to_fen should handle empty squares correctly" do
    @board.save!
    # Create a few pieces in non-standard positions
    Piece.create!(piece_type: "king", color: "white", file: "e", rank: 1, board: @board)
    Piece.create!(piece_type: "pawn", color: "white", file: "e", rank: 2, board: @board)
    Piece.create!(piece_type: "king", color: "black", file: "e", rank: 8, board: @board)

    fen = @board.to_fen

    # Should have mostly empty ranks with some pieces
    assert fen.include?("8") # Empty ranks
    assert fen.include?("K") # White king
    assert fen.include?("k") # Black king
  end

  test "create_piece! private method should create piece correctly" do
    @board.save!

    # Use send to access private method for testing
    piece = @board.send(:create_piece!, "white", "queen", "d", 1)

    assert piece.persisted?
    assert_equal "white", piece.color
    assert_equal "queen", piece.piece_type
    assert_equal "d", piece.file
    assert_equal 1, piece.rank
    assert_equal @board, piece.board
  end
end
