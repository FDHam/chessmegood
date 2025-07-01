# Issue #2: Create Todo model with validations and tests

**Issue Link**: https://github.com/FDHam/ai-todo-app/issues/2

## Requirements Analysis
Create a Todo model with proper ActiveRecord validations, database migration, and comprehensive test coverage.

## Task Breakdown

### 1. Database Schema & Migration
- [ ] Generate Todo model with migration
- [ ] Define table structure:
  - `title` (string, not null, indexed for searches)
  - `description` (text, nullable)
  - `completed` (boolean, default false, indexed for filtering)
  - `created_at` and `updated_at` (timestamps)
- [ ] Add database constraints and indexes for performance

### 2. Model Implementation
- [ ] Add validations:
  - Title: presence, length (3-100 characters)
  - Description: length (max 500 characters, optional)
  - Completed: inclusion in [true, false]
- [ ] Set default value for completed field
- [ ] Add scopes for common queries (completed, pending)

### 3. Factory & Test Setup
- [ ] Create Factory Bot factory for Todo
- [ ] Set up RSpec configuration if not already done
- [ ] Create model spec file with comprehensive tests

### 4. Testing Strategy
- [ ] Test all validations (valid/invalid cases)
- [ ] Test default values
- [ ] Test scopes and methods
- [ ] Test edge cases and boundary conditions
- [ ] Achieve >95% test coverage

### 5. Code Quality
- [ ] Run RuboCop to ensure style compliance
- [ ] Verify all tests pass
- [ ] Check database migration works correctly

## Implementation Notes
- Follow Rails conventions for naming and structure
- Use ActiveRecord validation helpers
- Implement comprehensive error messages
- Consider future requirements (user associations, categories, etc.)
- Ensure database constraints match model validations

## Definition of Done Checklist
- [ ] Todo model exists with all required validations
- [ ] Database migration creates proper table structure
- [ ] Factory Bot factory exists for testing
- [ ] Model tests achieve >95% coverage
- [ ] All tests pass locally
- [ ] RuboCop compliance
- [ ] Migration runs successfully
- [ ] Ready for pull request