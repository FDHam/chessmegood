class Game < ApplicationRecord
  # Enums
  enum :status, { pending: "pending", active: "active", completed: "completed", abandoned: "abandoned" }

  # Associations
  has_many :players, dependent: :destroy
  has_one :board, dependent: :destroy
  has_many :moves, dependent: :destroy
  belongs_to :current_player, class_name: "Player", optional: true

  # Validations
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :current_player, presence: true, if: :active?
  validate :current_player_belongs_to_game, if: :current_player
  validate :exactly_two_players, if: :active?

  # Scopes
  scope :active_games, -> { where(status: "active") }
  scope :completed_games, -> { where(status: "completed") }

  # Instance methods
  def start!
    return false unless can_start?

    transaction do
      update!(status: "active", current_player: white_player)
      create_board! if board.nil?
      initialize_pieces!
    end
  end

  def white_player
    players.find_by(color: "white")
  end

  def black_player
    players.find_by(color: "black")
  end

  def opponent_of(player)
    player == white_player ? black_player : white_player
  end

  def switch_current_player!
    update!(current_player: opponent_of(current_player))
  end

  private

  def can_start?
    pending? && players.count == 2 && white_player && black_player
  end

  def current_player_belongs_to_game
    errors.add(:current_player, "must belong to this game") unless players.include?(current_player)
  end

  def exactly_two_players
    errors.add(:players, "must have exactly two players") unless players.count == 2
  end

  def initialize_pieces!
    return unless board

    # This will be implemented later with proper chess piece setup
    board.setup_initial_position!
  end
end
