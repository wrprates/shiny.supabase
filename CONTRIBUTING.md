# Contributing to shiny.supabase

Thank you for considering contributing to shiny.supabase! 🎉

## How to Contribute

### 🐛 Reporting Bugs

1. **Check existing issues** first to avoid duplicates
2. **Use the bug report template** when creating new issues
3. **Provide minimal reproducible examples** when possible
4. **Include session information** with `sessionInfo()`

### ✨ Suggesting Features

1. **Check if the feature already exists** in the roadmap
2. **Describe the use case** clearly
3. **Provide examples** of how it would work
4. **Consider backward compatibility**

### 🛠️ Contributing Code

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Write your code** following the existing style
4. **Add tests** for new functionality
5. **Update documentation** if needed
6. **Run checks**: `devtools::check()`
7. **Submit a pull request**

## Development Setup

```r
# Install development dependencies
install.packages(c("devtools", "testthat", "roxygen2"))

# Clone and setup
git clone https://github.com/wrprates/shiny.supabase.git
cd shiny.supabase

# Load for development
devtools::load_all()

# Run tests
devtools::test()

# Build documentation
devtools::document()

# Check package
devtools::check()
```

## Code Style

- Follow existing code style and conventions
- Use meaningful variable and function names
- Write clear comments for complex logic
- Keep functions focused and small
- Use roxygen2 for documentation

## Testing

- Add tests for new functions in `tests/testthat/`
- Test files should be named `test-*.R`
- Use descriptive test names
- Test both success and failure cases
- Aim for good test coverage

## Documentation

- Use roxygen2 comments for all exported functions
- Update NEWS.md for user-facing changes
- Add examples to function documentation
- Update README.md if needed

## Pull Request Process

1. **Update documentation** and tests as needed
2. **Ensure all checks pass** (`R CMD check`)
3. **Write clear commit messages**
4. **Reference related issues** in PR description
5. **Be responsive** to review feedback

## Code of Conduct

This project follows a Code of Conduct. By participating, you agree to uphold this code:

- **Be respectful** and inclusive
- **Be collaborative** and helpful
- **Be patient** with newcomers
- **Be constructive** in feedback

## Questions?

- 💬 [GitHub Discussions](https://github.com/wrprates/shiny.supabase/discussions)
- 🐛 [GitHub Issues](https://github.com/wrprates/shiny.supabase/issues)
- 📧 Email: wrprates@yahoo.com

Thank you for helping make shiny.supabase better! 🚀