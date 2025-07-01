class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :status, null: false, default: 'pending'
      t.integer :current_player_id
      t.text :timer_settings

      t.timestamps
    end

    add_check_constraint :games, "status IN ('pending', 'active', 'completed', 'abandoned')", name: 'games_status_check'
    add_index :games, :status
    add_index :games, :current_player_id
    add_index :games, :created_at
  end
end
