# DEVOPS
A practical collection of infrastructure assets for automated deployments

## Version
**Current Release:** v1.0.0

## Versioning Strategy
This project follows [Semantic Versioning 2.0.0](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 1.0.0)
- **MAJOR**: Breaking changes to role interfaces or Docker configurations
- **MINOR**: New features, roles, or backward-compatible enhancements
- **PATCH**: Bug fixes and minor improvements

## Commit Convention
This project uses [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: New feature or role
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc. (no code change)
- `refactor`: Code refactoring (no feature change)
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependencies

### Examples
```
feat(jenkins): add Docker cloud configuration
fix(nexus): resolve SSL certificate validation error
docs: update README with versioning strategy
chore: update Ansible minimum version to 2.10
```

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for version history.
