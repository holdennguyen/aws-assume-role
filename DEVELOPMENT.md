# Development Guide

## 🔄 Git Flow Workflow

We use a modified Git Flow branching strategy to manage development:

### Branch Structure

- **`master`**: Production-ready code, tagged releases
- **`develop`**: Integration branch, latest development features  
- **`feature/*`**: New features and enhancements
- **`release/*`**: Release preparation and testing
- **`hotfix/*`**: Critical fixes for production issues

### Workflow Commands

#### Starting New Features
```bash
# Create and switch to feature branch
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name

# Work on your feature...
git add .
git commit -m "feat: implement your feature"

# Push feature branch
git push -u origin feature/your-feature-name
```

## 🧪 Testing Framework

### Test Structure

```
tests/
├── integration_tests.rs      # End-to-end CLI tests
├── common/mod.rs            # Test utilities and helpers
benches/
└── performance.rs           # Performance benchmarks
```

### Running Tests

#### All Tests
```bash
# Run complete test suite
cargo test

# Run with output  
cargo test -- --nocapture
```

#### Unit Tests Only
```bash
# Run library unit tests
cargo test --lib
```

#### Integration Tests
```bash
# Run all integration tests
cargo test --test integration_tests
```

#### Performance Benchmarks
```bash
# Run all benchmarks
cargo bench
```

### Test Coverage

```bash
# Install coverage tool
cargo install cargo-tarpaulin

# Generate coverage report
cargo tarpaulin --verbose --all-features --workspace --timeout 120
```

## 🏗️ Development Environment

### Prerequisites
- **Rust**: 1.70+ with stable toolchain
- **Git**: Configured with repository access
- **AWS CLI**: v2 for integration testing (optional)

### Setup
```bash
# Clone repository
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role

# Switch to develop branch
git checkout develop

# Install dependencies and build
cargo build

# Run tests to verify setup
cargo test
```

## 🚀 CI/CD Pipeline

### Quality Gates

All pull requests must pass:
1. ✅ **Formatting Check**: `cargo fmt --all -- --check`
2. ✅ **Linting**: `cargo clippy` with zero warnings
3. ✅ **Unit Tests**: All module tests passing
4. ✅ **Integration Tests**: CLI behavior verification
5. ✅ **Security Audit**: No known vulnerabilities
6. ✅ **Cross Compilation**: Linux, Windows, macOS builds

## 📝 Commit Standards

### Conventional Commits Format
```
type(scope): description
```

#### Types
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `test`: Test additions/modifications
- `refactor`: Code restructuring
- `perf`: Performance improvements
- `ci`: CI/CD configuration changes 