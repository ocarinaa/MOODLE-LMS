#  Contributing to Moodle LMS

Thank you for your interest in contributing to Moodle LMS! This document provides guidelines and instructions for contributing to this project.

##  Table of Contents

- [ Getting Started](#-getting-started)
- [ Development Setup](#-development-setup)
- [ Contributing Process](#-contributing-process)
- [ Coding Standards](#-coding-standards)
- [ Testing Guidelines](#-testing-guidelines)
- [ Documentation](#-documentation)
- [ Bug Reports](#-bug-reports)
- [ Feature Requests](#-feature-requests)
- [ Questions](#-questions)

---

##  Getting Started

### Prerequisites
- Docker (v20.10+)
- Docker Compose (v2.0+)
- Git
- Basic knowledge of containerization

### First-time Contributors
1. Fork the repository
2. Clone your fork locally
3. Set up the development environment
4. Make your changes
5. Test your changes
6. Submit a pull request

---

##  Development Setup

### 1. Clone the Repository
`ash
git clone https://github.com/YOUR-USERNAME/moodle-lms.git
cd moodle-lms
`

### 2. Set Up Development Environment
`ash
# Copy environment template
cp .env.example .env

# Start development environment
docker-compose up -d

# Wait for initialization (5-10 minutes)
# Access at http://localhost:8080
`

### 3. Verify Setup
`ash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f moodle
`

---

##  Contributing Process

### 1. Create a Branch
`ash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
`

### 2. Make Changes
- Keep changes focused and atomic
- Follow existing code patterns
- Update documentation as needed
- Add tests for new functionality

### 3. Test Your Changes
`ash
# Test locally
docker-compose down -v
docker-compose up -d

# Wait for initialization and test
curl http://localhost:8080
`

### 4. Commit Changes
`ash
git add .
git commit -m "type: description

Detailed explanation of changes made.

Fixes #issue-number"
`

### Commit Message Format
`
type: short description (50 chars max)

Longer explanation if needed. Wrap at 72 characters.
Explain what and why, not how.

- Bullet points are okay
- Use present tense: "add" not "added"
- Reference issues: "Fixes #123" or "Closes #456"
`

**Types:**
- eat: New feature
- ix: Bug fix
- docs: Documentation changes
- style: Code style changes
- efactor: Code refactoring
- 	est: Adding tests
- chore: Maintenance tasks

### 5. Push and Create PR
`ash
git push origin feature/your-feature-name
`

Then create a Pull Request through GitHub with:
- Clear title and description
- Reference to related issues
- Screenshots/demos if applicable
- Testing instructions

---

##  Coding Standards

### Docker Compose Guidelines
- Use official images when possible
- Pin image versions for stability
- Include health checks
- Use meaningful service names
- Document environment variables

### Documentation Standards
- Use clear, concise language
- Include code examples
- Keep README.md up to date
- Use proper Markdown formatting
- Add emojis for better readability

### Configuration Guidelines
- Use environment variables for configuration
- Provide sensible defaults
- Document security implications
- Separate development and production configs

---

##  Testing Guidelines

### Local Testing
`ash
# Clean environment test
docker-compose down -v
docker-compose up -d

# Wait for initialization
sleep 300

# Test HTTP access
curl -f http://localhost:8080

# Test HTTPS access (self-signed)
curl -k -f https://localhost:8443
`

### Automated Testing
- All PRs trigger GitHub Actions
- Tests must pass before merging
- Include new tests for new features
- Test both development and production scenarios

### Performance Testing
- Monitor container resource usage
- Test with realistic data volumes
- Verify startup times
- Check memory consumption

---

##  Documentation

### What to Document
- New features and configuration options
- Breaking changes
- Migration guides
- Troubleshooting steps
- API changes

### Documentation Location
- **README.md**: Main project documentation
- **docs/**: Detailed documentation
- **CHANGELOG.md**: Version history
- **Code comments**: Inline documentation

---

##  Bug Reports

### Before Reporting
1. Check existing issues
2. Test with latest version
3. Verify it's not a configuration issue
4. Test in clean environment

### Bug Report Template
`markdown
**Bug Description**
A clear description of the bug.

**Steps to Reproduce**
1. Step one
2. Step two
3. Step three

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- OS: [e.g. Ubuntu 20.04]
- Docker Version: [e.g. 20.10.14]
- Docker Compose Version: [e.g. 2.5.0]

**Logs**
`
Paste relevant logs here
`

**Additional Context**
Any other relevant information.
`

---

##  Feature Requests

### Before Requesting
1. Check if feature already exists
2. Search existing feature requests
3. Consider if it fits project scope
4. Think about implementation complexity

### Feature Request Template
`markdown
**Feature Description**
Clear description of the proposed feature.

**Use Case**
Why is this feature needed? What problem does it solve?

**Proposed Solution**
How do you think this should be implemented?

**Alternatives Considered**
What other approaches did you consider?

**Additional Context**
Any other relevant information, mockups, or examples.
`

---

##  Questions

### Getting Help
- **GitHub Discussions**: General questions and ideas
- **GitHub Issues**: Bug reports and feature requests
- **Documentation**: Check existing docs first

### Response Times
- We aim to respond to issues within 48 hours
- Complex issues may take longer to resolve
- Community help is always welcome

---

##  Recognition

Contributors will be:
- Listed in the project README
- Mentioned in release notes
- Given appropriate GitHub badges
- Invited to join the contributors team

---

##  License

By contributing to this project, you agree that your contributions will be licensed under the same MIT License that covers the project.

---

<div align="center">

**Thank you for contributing to Moodle LMS! **

*Together, we're building better educational technology.*

</div>
