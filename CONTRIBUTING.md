# Contributing to mcp-registry



## Development Setup

### Prerequisites

- Nix with flakes enabled
- `nix develop` for a development shell

### Quick Start

```bash
# Enter development shell
nix develop

# Build the project
nix build

# Run checks
nix flake check
```

## Code Style

- Follow existing patterns in the codebase
- Run `nix fmt` before committing (formats via treefmt)
- All commits should pass `nix flake check`

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run checks: `nix flake check`
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request

## Reporting Issues

- Use GitHub Issues for bugs and feature requests
- Include reproduction steps for bugs
- Mention your NixOS version and Nix version

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
