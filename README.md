# MCP Registry

NixOS module for declaring and managing MCP (Model Context Protocol) servers
used by AI coding tools (OpenCode, Qwen, Kimi, pi, etc.).

## Architecture

The registry is split into two files:

- **`mcp-server-registry.nix`** — Pure data registry of all known MCP servers
  (package names, types, entrypoints). Add new servers here.
- **`mcp-servers.nix`** — NixOS module that reads the registry and generates
  wrapper scripts (`mcp-<name>`) for each enabled server.

## Usage

### Import the module

```nix
{
  imports = [ /path/to/mcp-registry/nixosModules.default ];

  services.mcp-servers.enable = true;
}
```

### Enable specific servers

```nix
services.mcp-servers = {
  enable = true;

  servers.filesystem = {
    enable = true;
    allowedPaths = [ "$HOME" "/etc/nixos" ];
  };

  servers.git.enable = true;
  servers.playwright.enable = true;
  servers.fetch.enable = true;
  servers.context7.enable = true;
  servers.chrome-devtools.enable = true;
  servers.lightpanda.enable = true;
};
```

## Available servers

| Server       | Type    | Default  | Purpose                            |
|-------------|---------|----------|------------------------------------|
| filesystem  | npm     | enabled  | Local filesystem access            |
| git         | uvx     | enabled  | Git operations                     |
| fetch       | uvx     | enabled  | Web content fetching               |
| playwright  | custom  | enabled  | Browser automation                 |
| context7    | npm     | enabled  | Documentation search               |
| chrome-devtools | npm | enabled  | Chrome debugging                   |
| lightpanda  | custom  | enabled  | Headless browser (9x faster)       |
| fetch       | uvx     | enabled  | Web fetching                       |
| brave-search| npm     | disabled | Brave web search                   |
| github      | npm     | disabled | GitHub API                         |
| kubernetes  | custom  | disabled | Kubernetes cluster management      |
| n8n         | custom  | disabled | Workflow automation                |
| exa         | custom  | disabled | Exa web search                     |
| computer-use| custom  | disabled | Desktop automation                 |

## Adding a new server

1. Add an entry to `mcp-server-registry.nix`:

```nix
my-server = {
  type = "npm";  # or "uvx"
  package = "@scope/my-mcp-server";
};
```

2. Add enable option + config in `mcp-servers.nix` if the server needs
   custom wrapper logic.

## Generated commands

Each server gets a `mcp-<name>` wrapper script installed to the system
profile. AI tools reference these as their MCP server commands.

## Flakes

```nix
{
  inputs.mcp-registry.url = "path:/data/projects/own/mcp-registry";

  outputs = { nixpkgs, mcp-registry, ... }:
  {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [ mcp-registry.nixosModules.default ];
    };
  };
}
```
