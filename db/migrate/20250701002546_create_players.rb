class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.string :color, null: false
      t.references :game, null: false, foreign_key: true
      t.string :session_token

      t.timestamps
    end

    add_check_constraint :players, "color IN ('white', 'black')", name: 'players_color_check'
    add_check_constraint :players, "length(name) >= 1 AND length(name) <= 50", name: 'players_name_length_check'
    add_index :players, [ :game_id, :color ], unique: true
    add_index :players, :session_token, unique: true
  end
end
