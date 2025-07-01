require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @game = Game.new(status: "pending")
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @game.valid?
  end

  test "should require status" do
    @game.status = nil
    assert_not @game.valid?
    assert_includes @game.errors[:status], "can't be blank"
  end

  test "should validate status inclusion" do
    assert_raises ArgumentError do
      @game.status = "invalid"
    end
  end

  test "should default to pending status" do
    game = Game.create!
    assert_equal "pending", game.status
  end

  test "should require current_player when active" do
    @game.status = "active"
    assert_not @game.valid?
    assert_includes @game.errors[:current_player], "can't be blank"
  end

  test "should validate current_player belongs to game" do
    other_game = Game.create!(status: "pending")
    other_player = Player.create!(name: "Other", color: "white", game: other_game)

    @game.status = "active"
    @game.current_player = other_player
    assert_not @game.valid?
    assert_includes @game.errors[:current_player], "must belong to this game"
  end

  test "should require exactly two players when active" do
    @game.save! # Save the game first
    @game.status = "active"
    white_player = Player.create!(name: "White Player", color: "white", game: @game)
    @game.current_player = white_player

    assert_not @game.valid?
    assert_includes @game.errors[:players], "must have exactly two players"

    Player.create!(name: "Black Player", color: "black", game: @game)
    @game.reload
    assert @game.valid?
  end

  # Association tests
  test "should have many players" do
    game = Game.create!(status: "pending")
    player1 = Player.create!(name: "Player 1", color: "white", game: game)
    player2 = Player.create!(name: "Player 2", color: "black", game: game)

    assert_includes game.players, player1
    assert_includes game.players, player2
  end

  test "should have one board" do
    game = Game.create!(status: "pending")
    board = Board.create!(game: game)

    assert_equal board, game.board
  end

  test "should have many moves" do
    game = Game.create!(status: "pending")
    assert_respond_to game, :moves
  end

  test "should destroy dependent records when destroyed" do
    game = Game.create!(status: "pending")
    player = Player.create!(name: "Test Player", color: "white", game: game)
    board = Board.create!(game: game)

    assert_difference [ "Player.count", "Board.count" ], -1 do
      game.destroy
    end
  end

  # Scope tests
  test "active_games scope should return only active games" do
    # Create games with proper setup
    active_game = Game.create!(status: "pending")
    Player.create!(name: "White", color: "white", game: active_game)
    Player.create!(name: "Black", color: "black", game: active_game)
    active_game.start!

    pending_game = Game.create!(status: "pending")
    completed_game = Game.create!(status: "completed")

    active_games = Game.active_games
    assert_includes active_games, active_game
    assert_not_includes active_games, pending_game
    assert_not_includes active_games, completed_game
  end

  test "completed_games scope should return only completed games" do
    # Create active game with proper setup
    active_game = Game.create!(status: "pending")
    Player.create!(name: "White", color: "white", game: active_game)
    Player.create!(name: "Black", color: "black", game: active_game)
    active_game.start!

    pending_game = Game.create!(status: "pending")
    completed_game = Game.create!(status: "completed")

    completed_games = Game.completed_games
    assert_includes completed_games, completed_game
    assert_not_includes completed_games, active_game
    assert_not_includes completed_games, pending_game
  end

  # Instance method tests
  test "white_player should return white player" do
    game = Game.create!(status: "pending")
    white_player = Player.create!(name: "White", color: "white", game: game)
    Player.create!(name: "Black", color: "black", game: game)

    assert_equal white_player, game.white_player
  end

  test "black_player should return black player" do
    game = Game.create!(status: "pending")
    Player.create!(name: "White", color: "white", game: game)
    black_player = Player.create!(name: "Black", color: "black", game: game)

    assert_equal black_player, game.black_player
  end

  test "opponent_of should return the other player" do
    game = Game.create!(status: "pending")
    white_player = Player.create!(name: "White", color: "white", game: game)
    black_player = Player.create!(name: "Black", color: "black", game: game)

    assert_equal black_player, game.opponent_of(white_player)
    assert_equal white_player, game.opponent_of(black_player)
  end

  test "start! should transition from pending to active" do
    game = Game.create!(status: "pending")
    white_player = Player.create!(name: "White", color: "white", game: game)
    black_player = Player.create!(name: "Black", color: "black", game: game)

    result = game.start!

    assert result
    assert_equal "active", game.status
    assert_equal white_player, game.current_player
    assert_not_nil game.board
  end

  test "start! should fail if game cannot start" do
    game = Game.create!(status: "pending")
    # Missing players

    result = game.start!

    assert_not result
    assert_equal "pending", game.status
  end

  test "switch_current_player! should alternate between players" do
    game = Game.create!(status: "pending")
    white_player = Player.create!(name: "White", color: "white", game: game)
    black_player = Player.create!(name: "Black", color: "black", game: game)

    game.start!
    assert_equal white_player, game.current_player

    game.switch_current_player!
    assert_equal black_player, game.current_player

    game.switch_current_player!
    assert_equal white_player, game.current_player
  end
end
