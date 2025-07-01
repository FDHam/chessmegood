class CreatePieces < ActiveRecord::Migration[8.0]
  def change
    create_table :pieces do |t|
      t.string :piece_type, null: false
      t.string :color, null: false
      t.string :file, null: false
      t.integer :rank, null: false
      t.boolean :captured, default: false, null: false
      t.references :board, null: false, foreign_key: true

      t.timestamps
    end

    add_check_constraint :pieces, "piece_type IN ('pawn', 'rook', 'knight', 'bishop', 'queen', 'king')", name: 'pieces_type_check'
    add_check_constraint :pieces, "color IN ('white', 'black')", name: 'pieces_color_check'
    add_check_constraint :pieces, "file IN ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h')", name: 'pieces_file_check'
    add_check_constraint :pieces, "rank >= 1 AND rank <= 8", name: 'pieces_rank_check'

    add_index :pieces, [ :board_id, :file, :rank ], unique: true, where: "captured = false", name: 'unique_position_when_not_captured'
    add_index :pieces, [ :board_id, :color, :piece_type ]
    add_index :pieces, :captured
  end
end
