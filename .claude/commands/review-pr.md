# Code Review

Review a pull request using Sandy Mets principles and Rails best practices.

## Usage
/review-pr <pr_number>

## Instructions

1. **Fetch PR Details**:
   - Use `gh pr view {{arg1}}` to get PR information
   - Use `gh pr diff {{arg1}}` to see changes
   - Review linked issues and requirements

2. **Code Quality Review**:
   - **Single Responsibility**: Each class/method has one reason to change
   - **DRY Principle**: No repeated code patterns
   - **Clear Naming**: Methods and variables express intent clearly
   - **Small Methods**: Keep methods focused and short (< 10 lines ideal)
   - **Rails Conventions**: Follow Rails naming and structure conventions

3. **Security and Performance**:
   - Check for SQL injection vulnerabilities
   - Verify proper parameter sanitization
   - Look for N+1 query problems
   - Ensure proper error handling
   - Check for XSS vulnerabilities

4. **Testing Review**:
   - Verify comprehensive test coverage
   - Check test quality and readability
   - Ensure edge cases are covered
   - Verify feature tests cover user workflows

5. **Accessibility and UX**:
   - Check semantic HTML usage
   - Verify keyboard navigation
   - Test responsive design
   - Ensure proper error messages

6. **Provide Constructive Feedback**:
   - Highlight positive aspects
   - Suggest specific improvements with examples
   - Reference Rails guides and best practices
   - Prioritize feedback (critical vs. nice-to-have)

## Review Checklist
- [ ] Code follows Rails conventions
- [ ] Tests are comprehensive and well-written
- [ ] No security vulnerabilities identified
- [ ] Performance considerations addressed
- [ ] Accessibility guidelines followed
- [ ] Error handling is appropriate
- [ ] Documentation is updated if needed