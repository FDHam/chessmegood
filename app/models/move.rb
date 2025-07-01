class Move < ApplicationRecord
  # Associations
  belongs_to :piece
  belongs_to :player
  belongs_to :game
  has_one :board, through: :game

  # Validations
  validates :from_file, presence: true, inclusion: { in: %w[a b c d e f g h] }
  validates :to_file, presence: true, inclusion: { in: %w[a b c d e f g h] }
  validates :from_rank, presence: true, inclusion: { in: 1..8 }
  validates :to_rank, presence: true, inclusion: { in: 1..8 }
  validates :algebraic_notation, length: { maximum: 10 }

  validate :different_positions
  validate :valid_move_for_piece
  validate :player_owns_piece
  validate :game_is_active

  # Callbacks
  before_validation :generate_algebraic_notation, if: :new_record?
  after_create :execute_move!

  # Scopes
  scope :chronological, -> { order(:created_at) }
  scope :by_game, ->(game) { where(game: game) }
  scope :by_player, ->(player) { where(player: player) }

  # Instance methods
  def from_position
    "#{from_file}#{from_rank}"
  end

  def to_position
    "#{to_file}#{to_rank}"
  end

  def is_capture?
    # Check if there was a piece at the destination
    board.piece_at(to_file, to_rank).present?
  end

  def is_castling?
    piece.king? && (to_file == "g" || to_file == "c") && from_file == "e"
  end

  def is_en_passant?
    piece.pawn? && from_file != to_file && board.empty_at?(to_file, to_rank)
  end

  def to_s
    algebraic_notation || "#{from_position}-#{to_position}"
  end

  private

  def different_positions
    if from_file == to_file && from_rank == to_rank
      errors.add(:base, "Move must be to a different position")
    end
  end

  def valid_move_for_piece
    return unless piece && from_file && from_rank && to_file && to_rank

    # Check if piece is at the from position
    unless piece.file == from_file && piece.rank == from_rank
      errors.add(:piece, "is not at the from position")
    end

    # Check if move is valid for this piece type
    unless piece.can_move_to?(to_file, to_rank)
      errors.add(:base, "is not a valid move for this piece")
    end
  end

  def player_owns_piece
    return unless piece && player

    unless piece.color == player.color
      errors.add(:player, "does not own this piece")
    end
  end

  def game_is_active
    return unless game

    unless game.active?
      errors.add(:game, "is not active")
    end
  end

  def generate_algebraic_notation
    return if algebraic_notation.present?

    # Basic algebraic notation - will be enhanced later
    notation = ""

    # Piece designation (except for pawns)
    notation += piece.piece_type.first.upcase unless piece.pawn?

    # Capture indicator
    if is_capture?
      notation += piece.pawn? ? from_file : ""
      notation += "x"
    end

    # Destination square
    notation += to_position

    # Special moves
    notation += "+" if puts_opponent_in_check?
    notation += "#" if checkmate?
    notation = "O-O" if is_castling? && to_file == "g"
    notation = "O-O-O" if is_castling? && to_file == "c"

    self.algebraic_notation = notation
  end

  def execute_move!
    return unless valid?

    piece.move_to!(to_file, to_rank)
    game.switch_current_player!
  end

  def puts_opponent_in_check?
    # Simplified check detection - will be enhanced later
    false
  end

  def checkmate?
    # Simplified checkmate detection - will be enhanced later
    false
  end
end
