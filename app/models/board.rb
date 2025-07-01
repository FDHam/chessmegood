class Board < ApplicationRecord
  # Associations
  belongs_to :game
  has_many :pieces, dependent: :destroy

  # Validations
  validates :game_id, uniqueness: true

  # Constants
  FILES = %w[a b c d e f g h].freeze
  RANKS = (1..8).to_a.freeze

  # Instance methods
  def setup_initial_position!
    return if pieces.any?

    transaction do
      # Setup white pieces
      create_piece!("white", "rook", "a", 1)
      create_piece!("white", "knight", "b", 1)
      create_piece!("white", "bishop", "c", 1)
      create_piece!("white", "queen", "d", 1)
      create_piece!("white", "king", "e", 1)
      create_piece!("white", "bishop", "f", 1)
      create_piece!("white", "knight", "g", 1)
      create_piece!("white", "rook", "h", 1)

      FILES.each { |file| create_piece!("white", "pawn", file, 2) }

      # Setup black pieces
      create_piece!("black", "rook", "a", 8)
      create_piece!("black", "knight", "b", 8)
      create_piece!("black", "bishop", "c", 8)
      create_piece!("black", "queen", "d", 8)
      create_piece!("black", "king", "e", 8)
      create_piece!("black", "bishop", "f", 8)
      create_piece!("black", "knight", "g", 8)
      create_piece!("black", "rook", "h", 8)

      FILES.each { |file| create_piece!("black", "pawn", file, 7) }

      refresh_position_data!
    end
  end

  def piece_at(file, rank)
    pieces.find_by(file: file, rank: rank, captured: false)
  end

  def empty_at?(file, rank)
    piece_at(file, rank).nil?
  end

  def valid_position?(file, rank)
    FILES.include?(file) && RANKS.include?(rank)
  end

  def refresh_position_data!
    position_hash = {}
    pieces.active.each do |piece|
      position_hash["#{piece.file}#{piece.rank}"] = {
        type: piece.piece_type,
        color: piece.color,
        id: piece.id
      }
    end
    update!(position_data: position_hash)
  end

  def to_fen
    # Simplified FEN generation - will be expanded later
    fen_rows = []
    8.downto(1) do |rank|
      row = ""
      empty_count = 0

      FILES.each do |file|
        piece = piece_at(file, rank)
        if piece
          row += empty_count.to_s if empty_count > 0
          row += piece.to_fen_char
          empty_count = 0
        else
          empty_count += 1
        end
      end

      row += empty_count.to_s if empty_count > 0
      fen_rows << row
    end

    fen_rows.join("/")
  end

  private

  def create_piece!(color, piece_type, file, rank)
    pieces.create!(
      color: color,
      piece_type: piece_type,
      file: file,
      rank: rank
    )
  end
end
