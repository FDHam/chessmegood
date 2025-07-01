require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  def setup
    @game = Game.create!(status: "pending")
    @player = Player.new(name: "Test Player", color: "white", game: @game)
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @player.valid?
  end

  test "should require name" do
    @player.name = nil
    assert_not @player.valid?
    assert_includes @player.errors[:name], "can't be blank"
  end

  test "should require name with minimum length" do
    @player.name = ""
    assert_not @player.valid?
    assert_includes @player.errors[:name], "is too short (minimum is 1 character)"
  end

  test "should require name with maximum length" do
    @player.name = "a" * 51
    assert_not @player.valid?
    assert_includes @player.errors[:name], "is too long (maximum is 50 characters)"
  end

  test "should require color" do
    @player.color = nil
    assert_not @player.valid?
    assert_includes @player.errors[:color], "can't be blank"
  end

  test "should validate color inclusion" do
    assert_raises ArgumentError do
      @player.color = "invalid"
    end
  end

  test "should require unique color per game" do
    @player.save!
    duplicate_player = Player.new(name: "Another Player", color: "white", game: @game)

    assert_not duplicate_player.valid?
    assert_includes duplicate_player.errors[:color], "already exists in this game"
  end

  test "should allow same color in different games" do
    @player.save!
    other_game = Game.create!(status: "pending")
    other_player = Player.new(name: "Other Player", color: "white", game: other_game)

    assert other_player.valid?
  end

  test "should require unique session_token" do
    @player.save!
    other_game = Game.create!(status: "pending")
    other_player = Player.new(name: "Other", color: "black", game: other_game)
    other_player.session_token = @player.session_token

    assert_not other_player.valid?
    assert_includes other_player.errors[:session_token], "has already been taken"
  end

  test "should allow blank session_token" do
    @player.session_token = nil
    assert @player.valid?

    @player.session_token = ""
    assert @player.valid?
  end

  # Association tests
  test "should belong to game" do
    assert_equal @game, @player.game
  end

  test "should have many moves" do
    @player.save!
    assert_respond_to @player, :moves
  end

  # Callback tests
  test "should generate session_token on create if blank" do
    @player.session_token = nil
    @player.save!

    assert_not_nil @player.session_token
    assert_equal 32, @player.session_token.length
  end

  test "should not overwrite existing session_token" do
    custom_token = "custom_token_123"
    @player.session_token = custom_token
    @player.save!

    assert_equal custom_token, @player.session_token
  end

  # Scope tests
  test "white_players scope should return only white players" do
    white_player = Player.create!(name: "White", color: "white", game: @game)
    black_player = Player.create!(name: "Black", color: "black", game: @game)

    white_players = Player.white_players
    assert_includes white_players, white_player
    assert_not_includes white_players, black_player
  end

  test "black_players scope should return only black players" do
    white_player = Player.create!(name: "White", color: "white", game: @game)
    black_player = Player.create!(name: "Black", color: "black", game: @game)

    black_players = Player.black_players
    assert_includes black_players, black_player
    assert_not_includes black_players, white_player
  end

  # Instance method tests
  test "opponent should return the other player in the game" do
    @player.save!
    opponent = Player.create!(name: "Opponent", color: "black", game: @game)

    assert_equal opponent, @player.opponent
    assert_equal @player, opponent.opponent
  end

  test "is_current_player? should return true when it's player's turn" do
    @player.save!
    opponent = Player.create!(name: "Opponent", color: "black", game: @game)
    @game.start!

    # White player starts first
    assert @player.is_current_player?
    assert_not opponent.is_current_player?

    @game.switch_current_player!

    assert_not @player.is_current_player?
    assert opponent.is_current_player?
  end

  test "can_move? should return true when game is active and it's player's turn" do
    @player.save!
    opponent = Player.create!(name: "Opponent", color: "black", game: @game)

    # Game is pending
    assert_not @player.can_move?

    @game.start!

    # Game is active and it's white player's turn
    assert @player.can_move?
    assert_not opponent.can_move?

    @game.switch_current_player!

    # Now it's black player's turn
    assert_not @player.can_move?
    assert opponent.can_move?
  end

  # Enum tests
  test "should have white and black color enums" do
    assert Player.colors.key?("white")
    assert Player.colors.key?("black")
    assert_equal 2, Player.colors.size
  end

  test "should respond to color predicate methods" do
    @player.color = "white"
    assert @player.white?
    assert_not @player.black?

    @player.color = "black"
    assert @player.black?
    assert_not @player.white?
  end
end
