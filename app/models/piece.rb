class Piece < ApplicationRecord
  # Enums
  enum :piece_type, {
    pawn: "pawn",
    rook: "rook",
    knight: "knight",
    bishop: "bishop",
    queen: "queen",
    king: "king"
  }

  enum :color, { white: "white", black: "black" }

  # Associations
  belongs_to :board
  has_many :moves, dependent: :destroy
  has_one :game, through: :board

  # Validations
  validates :piece_type, presence: true, inclusion: { in: piece_types.keys }
  validates :color, presence: true, inclusion: { in: colors.keys }
  validates :file, presence: true, inclusion: { in: %w[a b c d e f g h] }
  validates :rank, presence: true, inclusion: { in: 1..8 }
  validates :captured, inclusion: { in: [ true, false ] }

  # Position must be unique when not captured
  validates :file, uniqueness: { scope: [ :board_id, :rank ], conditions: -> { where(captured: false) } }

  # Scopes
  scope :active, -> { where(captured: false) }
  scope :captured, -> { where(captured: true) }
  scope :by_color, ->(color) { where(color: color) }
  scope :by_type, ->(type) { where(piece_type: type) }

  # Instance methods
  def position
    "#{file}#{rank}"
  end

  def capture!
    update!(captured: true)
    board.refresh_position_data!
  end

  def move_to!(new_file, new_rank)
    return false unless can_move_to?(new_file, new_rank)

    transaction do
      # Capture piece at destination if present
      target_piece = board.piece_at(new_file, new_rank)
      target_piece&.capture!

      # Move this piece
      update!(file: new_file, rank: new_rank)
      board.refresh_position_data!
    end

    true
  end

  def can_move_to?(target_file, target_rank)
    return false unless board.valid_position?(target_file, target_rank)
    return false if file == target_file && rank == target_rank

    target_piece = board.piece_at(target_file, target_rank)
    return false if target_piece && target_piece.color == color

    # Basic validation - specific piece movement rules will be added later
    true
  end

  def to_fen_char
    char = case piece_type
    when "pawn" then "p"
    when "rook" then "r"
    when "knight" then "n"
    when "bishop" then "b"
    when "queen" then "q"
    when "king" then "k"
    end

    white? ? char.upcase : char
  end

  def same_color?(other_piece)
    color == other_piece.color
  end

  def opponent_color?(other_piece)
    color != other_piece.color
  end

  def player
    game.players.find_by(color: color)
  end
end
