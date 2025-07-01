class CreateBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :boards do |t|
      t.references :game, null: false, foreign_key: true, index: { unique: true }
      t.jsonb :position_data, default: '{}'

      t.timestamps
    end

    add_index :boards, :position_data, using: :gin
  end
end
