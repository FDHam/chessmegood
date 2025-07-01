# AI Todo App

A Rails application for managing todos with AI-powered development workflow.

## Project Overview
This application demonstrates a complete AI coding workflow using Claude Code, GitHub, and modern Rails development practices. It serves as both a functional todo application and a reference implementation for AI-assisted development.

## Technology Stack
- **Backend**: Ruby 3.2.0, Rails 7.1
- **Database**: PostgreSQL 14+
- **Frontend**: Stimulus, Turbo, Tailwind CSS
- **Testing**: RSpec, Capybara, Factory Bot
- **CI/CD**: GitHub Actions
- **Development**: VS Code with WSL/Ubuntu
- **AI Tools**: Claude Code with MCP servers

## Development Environment
- **OS**: WSL/Ubuntu in Windows
- **Editor**: VS Code with Remote-WSL extension
- **Terminal**: Integrated VS Code terminal (WSL bash)
- **Browser Testing**: Chrome headless via Selenium

## Development Conventions

### Models
- Use ActiveRecord conventions for naming and associations
- Include comprehensive validations with meaningful error messages
- Write model tests covering all validations and business logic
- Use scopes for common queries
- Keep models focused on data and business logic only

### Controllers
- Keep controller actions thin (< 10 lines)
- Extract complex logic to service objects or concerns
- Use strong parameters for all user input
- Return appropriate HTTP status codes
- Handle errors gracefully with proper responses
- Write controller tests for all actions and error conditions

### Views
- Use semantic HTML5 elements
- Ensure accessibility with proper ARIA labels and roles
- Make responsive with Tailwind CSS utilities
- Use Rails helpers and partials for reusability
- Follow Rails naming conventions for templates

### JavaScript
- Use Stimulus controllers for interactive elements
- Keep JavaScript logic simple and focused
- Test JavaScript functionality with Capybara/Selenium
- Prefer progressive enhancement over JavaScript-dependent features

### Testing Strategy
- Maintain >90% test coverage
- Write feature tests for complete user workflows
- Use factory_bot for consistent test data
- Test both happy path and edge cases
- Include browser automation tests for UI interactions
- Run tests in CI/CD pipeline for all PRs

### Code Style
- Follow RuboCop Rails configuration
- Use descriptive method and variable names
- Keep methods short and focused
- Write self-documenting code with minimal comments
- Follow Rails conventions for file organization

## Project Structure