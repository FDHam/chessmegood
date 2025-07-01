# Issue #1: Setup Chessmegood Foundation - Implementation Plan

**Original Issue**: https://github.com/FDHam/chessmegood/issues/1

## Project Vision
Create chessmegood - a stunning chess webapp with:
- Cell-shaded Viewtiful Joe aesthetics
- Isometric table perspective
- Star Wars Imperial/Sith pieces
- Vaporwave + Dark Academia themes
- Desert/Ocean/Forest environments

## Implementation Breakdown

### Phase 1: Core Models & Database Schema

#### 1. Game Model
```ruby
# app/models/game.rb
- Fields: status (enum: pending, active, completed, abandoned), current_player_id, timer_settings, created_at, updated_at
- Status: pending -> active -> completed/abandoned
- Associations: has_many :players, has_one :board, has_many :moves
- Validations: status presence, current_player belongs to game
```

#### 2. Player Model  
```ruby
# app/models/player.rb
- Fields: name, color (enum: white, black), game_id, session_token, created_at
- Associations: belongs_to :game, has_many :moves
- Validations: name presence, color inclusion, unique color per game
```

#### 3. Board Model
```ruby
# app/models/board.rb
- Fields: game_id, position_data (JSON for 8x8 grid state)
- Associations: belongs_to :game, has_many :pieces
- Methods: position_at(file, rank), update_position, valid_position?
```

#### 4. Piece Model
```ruby
# app/models/piece.rb
- Fields: type (enum: pawn, rook, knight, bishop, queen, king), color, file, rank, captured, board_id
- Associations: belongs_to :board, has_many :moves
- Validations: type/color presence, position within bounds, unique position when not captured
- Methods: valid_moves, can_move_to?, capture!
```

#### 5. Move Model
```ruby
# app/models/move.rb  
- Fields: from_file, from_rank, to_file, to_rank, piece_id, player_id, game_id, algebraic_notation, created_at
- Associations: belongs_to :piece, belongs_to :player, belongs_to :game
- Validations: coordinate bounds, move legality
- Methods: to_algebraic, execute!, undo!
```

### Phase 2: Database Migrations

#### Tables to Create:
1. `games` - status, current_player_id, timer_settings, timestamps
2. `players` - name, color, game_id, session_token, timestamps  
3. `boards` - game_id, position_data (jsonb), timestamps
4. `pieces` - type, color, file, rank, captured, board_id, timestamps
5. `moves` - coordinates, piece_id, player_id, game_id, notation, timestamps

#### Constraints:
- Foreign key constraints with proper cascading
- Unique indexes on (game_id, color) for players
- Unique indexes on (board_id, file, rank) for uncaptured pieces
- Check constraints for coordinate bounds (a-h, 1-8)
- Enum constraints for piece types and colors

### Phase 3: Model Validations & Associations

#### Game Model:
- Status enum validation
- Current player must belong to game
- Timer settings format validation

#### Player Model: 
- Name presence and uniqueness within game
- Color uniqueness within game
- Session token uniqueness

#### Board Model:
- Position data JSON schema validation
- Game association presence

#### Piece Model:
- Chess piece type validation
- Position bounds validation (a1-h8)
- Color consistency with player
- No two pieces on same square (when not captured)

#### Move Model:
- Coordinate validation (within board)
- Move legality validation
- Algebraic notation format
- Timestamp ordering within game

### Phase 4: Chess-Specific Business Logic

#### Game Logic:
- Turn management (alternating white/black)
- Check/checkmate detection
- Stalemate detection
- Draw conditions (50-move rule, repetition)

#### Piece Movement:
- Piece-specific move validation
- En passant handling
- Castling rules
- Pawn promotion

#### Board State:
- FEN (Forsyth-Edwards Notation) export/import
- Position hashing for repetition detection
- Board visualization helpers

### Phase 5: Testing Strategy

#### Model Tests:
- Validation tests for all models
- Association tests
- Chess rule enforcement tests
- Edge case handling (invalid moves, game states)

#### Integration Tests:
- Complete game workflow tests
- Move execution and board state updates
- Game state transitions

#### Test Data:
- Factory Bot factories for consistent test data
- Fixtures for common chess positions
- Test games with known outcomes

### Phase 6: CSS Foundation (Isometric/Cell-Shaded)

#### Core Styles:
```scss
// Isometric perspective transforms
.chess-board {
  transform: rotateX(60deg) rotateY(0deg) rotateZ(45deg);
  transform-style: preserve-3d;
}

// Cell-shaded piece styling
.chess-piece {
  filter: contrast(1.2) saturate(1.3);
  image-rendering: pixelated;
  border: 2px solid rgba(0,0,0,0.8);
}

// Vaporwave color palette
:root {
  --vaporwave-pink: #ff006e;
  --vaporwave-blue: #8338ec;
  --vaporwave-cyan: #06ffa5;
  --dark-academia: #2d1b14;
}
```

#### Environment Themes:
- Desert: warm oranges, sand textures
- Ocean: blues, wave patterns
- Forest: greens, organic textures

## Implementation Order

1. ✅ **Setup Planning** - Create scratchpad and breakdown
2. **Generate Models** - Use Rails generators for basic structure
3. **Create Migrations** - Database schema with constraints
4. **Add Validations** - Business logic and data integrity
5. **Write Tests** - Comprehensive coverage of chess rules
6. **CSS Foundation** - Basic isometric styling
7. **Test & Lint** - Ensure code quality
8. **Commit & PR** - Deploy changes

## Success Criteria

- [ ] All 5 core models created with proper associations
- [ ] Database migrations with chess-specific constraints  
- [ ] Comprehensive validations for chess rules
- [ ] >90% test coverage on all models
- [ ] Basic isometric CSS foundation
- [ ] Clean RuboCop linting
- [ ] All tests passing
- [ ] PR created linking to issue #1

## Technical Considerations

### Database Design:
- Use JSONB for board position data (PostgreSQL)
- Proper indexing for game queries
- Foreign key constraints for data integrity

### Chess Rules Implementation:
- Separate move validation from move execution
- Immutable move history for game replay
- Efficient check/checkmate detection

### Performance:
- Indexed queries for active games
- Optimized piece position lookups
- Minimal database calls for move validation

### Testing:
- Test common chess scenarios (checkmate patterns)
- Edge cases (en passant, castling, promotion)
- Invalid move rejection
- Game state consistency