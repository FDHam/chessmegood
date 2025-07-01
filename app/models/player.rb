class Player < ApplicationRecord
  # Enums
  enum :color, { white: "white", black: "black" }

  # Associations
  belongs_to :game
  has_many :moves, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :color, presence: true, inclusion: { in: colors.keys }
  validates :color, uniqueness: { scope: :game_id, message: "already exists in this game" }
  validates :session_token, uniqueness: true, allow_blank: true

  # Callbacks
  before_validation :generate_session_token, if: :new_record?

  # Scopes
  scope :white_players, -> { where(color: "white") }
  scope :black_players, -> { where(color: "black") }

  # Instance methods
  def opponent
    game.opponent_of(self)
  end

  def is_current_player?
    game.current_player == self
  end

  def can_move?
    game.active? && is_current_player?
  end

  private

  def generate_session_token
    self.session_token = SecureRandom.hex(16) if session_token.blank?
  end
end
