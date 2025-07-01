# Process GitHub Issue

Process a GitHub issue from planning through deployment.

## Usage
/process-issue <issue_number>

## Instructions

### Phase 1: PLAN
1. **Think harder** about this issue and understand the requirements
2. Use `gh issue view {{arg1}}` to read the full issue details
3. Search existing scratchpads in `.claude/scratchpads/` for related work
4. Review previous PRs using `gh pr list --state merged --limit 10` for context
5. Break down the issue into small, atomic, manageable tasks
6. Create a new scratchpad file: `.claude/scratchpads/issue-{{arg1}}-plan.md`
7. Include link to original issue and detailed task breakdown

### Phase 2: CREATE
1. Implement the planned changes following the task breakdown
2. Follow existing code patterns and conventions from `claude.md`
3. Use Rails generators when appropriate (`rails generate model`, `rails generate controller`)
4. Write comprehensive tests for all new functionality
5. Ensure code follows project style guide and Rails conventions

### Phase 3: TEST
1. Run the full test suite: `bundle exec rspec`
2. Run linter with auto-correction: `bundle exec rubocop --auto-correct`
3. Use Puppeteer to test UI changes if applicable:
   - Start Rails server: `rails server`
   - Navigate to relevant pages
   - Test user interactions
   - Verify functionality works as expected
4. Check that all tests pass and no regressions introduced

### Phase 4: DEPLOY
1. Commit changes with descriptive commit message following conventional commits
2. Create pull request using: `gh pr create --title "Brief description" --body "Closes #{{arg1}}"`
3. Include summary of changes and link to original issue
4. Ensure all checks pass before requesting review

## Rules
- Each phase must complete successfully before proceeding
- Always write tests for new functionality  
- Follow Rails conventions and best practices
- Use descriptive commit messages with issue references
- Link PRs to original issues using "Closes #123" syntax
- Test both happy path and edge cases
- Ensure responsive design for UI changes