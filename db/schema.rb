# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_01_002617) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "boards", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.jsonb "position_data", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_boards_on_game_id", unique: true
    t.index ["position_data"], name: "index_boards_on_position_data", using: :gin
  end

  create_table "games", force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.integer "current_player_id"
    t.text "timer_settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_games_on_created_at"
    t.index ["current_player_id"], name: "index_games_on_current_player_id"
    t.index ["status"], name: "index_games_on_status"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'active'::character varying, 'completed'::character varying, 'abandoned'::character varying]::text[])", name: "games_status_check"
  end

  create_table "moves", force: :cascade do |t|
    t.string "from_file", null: false
    t.integer "from_rank", null: false
    t.string "to_file", null: false
    t.integer "to_rank", null: false
    t.string "algebraic_notation"
    t.bigint "piece_id", null: false
    t.bigint "player_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["algebraic_notation"], name: "index_moves_on_algebraic_notation"
    t.index ["game_id", "created_at"], name: "index_moves_on_game_id_and_created_at"
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["piece_id"], name: "index_moves_on_piece_id"
    t.index ["player_id"], name: "index_moves_on_player_id"
    t.check_constraint "NOT (from_file::text = to_file::text AND from_rank = to_rank)", name: "moves_different_positions_check"
    t.check_constraint "from_file::text = ANY (ARRAY['a'::character varying, 'b'::character varying, 'c'::character varying, 'd'::character varying, 'e'::character varying, 'f'::character varying, 'g'::character varying, 'h'::character varying]::text[])", name: "moves_from_file_check"
    t.check_constraint "from_rank >= 1 AND from_rank <= 8", name: "moves_from_rank_check"
    t.check_constraint "to_file::text = ANY (ARRAY['a'::character varying, 'b'::character varying, 'c'::character varying, 'd'::character varying, 'e'::character varying, 'f'::character varying, 'g'::character varying, 'h'::character varying]::text[])", name: "moves_to_file_check"
    t.check_constraint "to_rank >= 1 AND to_rank <= 8", name: "moves_to_rank_check"
  end

  create_table "pieces", force: :cascade do |t|
    t.string "piece_type", null: false
    t.string "color", null: false
    t.string "file", null: false
    t.integer "rank", null: false
    t.boolean "captured", default: false, null: false
    t.bigint "board_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id", "color", "piece_type"], name: "index_pieces_on_board_id_and_color_and_piece_type"
    t.index ["board_id", "file", "rank"], name: "unique_position_when_not_captured", unique: true, where: "(captured = false)"
    t.index ["board_id"], name: "index_pieces_on_board_id"
    t.index ["captured"], name: "index_pieces_on_captured"
    t.check_constraint "color::text = ANY (ARRAY['white'::character varying, 'black'::character varying]::text[])", name: "pieces_color_check"
    t.check_constraint "file::text = ANY (ARRAY['a'::character varying, 'b'::character varying, 'c'::character varying, 'd'::character varying, 'e'::character varying, 'f'::character varying, 'g'::character varying, 'h'::character varying]::text[])", name: "pieces_file_check"
    t.check_constraint "piece_type::text = ANY (ARRAY['pawn'::character varying, 'rook'::character varying, 'knight'::character varying, 'bishop'::character varying, 'queen'::character varying, 'king'::character varying]::text[])", name: "pieces_type_check"
    t.check_constraint "rank >= 1 AND rank <= 8", name: "pieces_rank_check"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", null: false
    t.bigint "game_id", null: false
    t.string "session_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "color"], name: "index_players_on_game_id_and_color", unique: true
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["session_token"], name: "index_players_on_session_token", unique: true
    t.check_constraint "color::text = ANY (ARRAY['white'::character varying, 'black'::character varying]::text[])", name: "players_color_check"
    t.check_constraint "length(name::text) >= 1 AND length(name::text) <= 50", name: "players_name_length_check"
  end

  add_foreign_key "boards", "games"
  add_foreign_key "moves", "games"
  add_foreign_key "moves", "pieces"
  add_foreign_key "moves", "players"
  add_foreign_key "pieces", "boards"
  add_foreign_key "players", "games"
end
