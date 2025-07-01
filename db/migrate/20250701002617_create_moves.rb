class CreateMoves < ActiveRecord::Migration[8.0]
  def change
    create_table :moves do |t|
      t.string :from_file, null: false
      t.integer :from_rank, null: false
      t.string :to_file, null: false
      t.integer :to_rank, null: false
      t.string :algebraic_notation
      t.references :piece, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end

    add_check_constraint :moves, "from_file IN ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h')", name: 'moves_from_file_check'
    add_check_constraint :moves, "to_file IN ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h')", name: 'moves_to_file_check'
    add_check_constraint :moves, "from_rank >= 1 AND from_rank <= 8", name: 'moves_from_rank_check'
    add_check_constraint :moves, "to_rank >= 1 AND to_rank <= 8", name: 'moves_to_rank_check'
    add_check_constraint :moves, "NOT (from_file = to_file AND from_rank = to_rank)", name: 'moves_different_positions_check'

    add_index :moves, [ :game_id, :created_at ]
    add_index :moves, :algebraic_notation
  end
end
