{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mcp-servers;

  registry = import ./mcp-server-registry.nix { inherit lib; };


  mkNpmMcpServer =
    {
      name,
      package,
      args ? [ ],
      env ? { },
    }:
    pkgs.writeShellScriptBin "mcp-${name}" ''
      export npm_config_cache="/var/cache/ai-inference/npm"
      export PATH="${pkgs.nodejs_22}/bin:$PATH"
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          k: v:
          if lib.hasSuffix "_FILE" k then
            ''
              if [ -f "${v}" ]; then
                export ${lib.substring 0 (lib.stringLength k - 5) k}="$(cat ${v})"
              else
                echo "Warning: API key file not found: ${v}" >&2
              fi
            ''
          else
            ''
              export ${k}="${v}"
            ''
        ) env
      )}
      exec ${pkgs.nodejs_22}/bin/npx -y ${package} ${lib.concatStringsSep " " args} "$@"
    '';

  mkUvxMcpServer =
    {
      name,
      package,
      entrypoint,
    }:
    pkgs.writeShellScriptBin "mcp-${name}" ''
      export PATH="${pkgs.uv}/bin:$PATH"
      exec ${pkgs.uv}/bin/uvx --from ${package} ${entrypoint} "$@"
    '';

  mkMcpServer =
    name: def:
    if def.type == "npm" then
      mkNpmMcpServer {
        inherit name;
        inherit (def) package;
        args = def.args or [ ];
        env = def.env or { };
      }
    else if def.type == "uvx" then
      mkUvxMcpServer {
        inherit name;
        inherit (def) package entrypoint;
      }
    else
      null;

  registryPackages = lib.filter (p: p != null) (lib.mapAttrsToList mkMcpServer registry.servers);
in
{
  options.services.mcp-servers = {
    enable = lib.mkEnableOption "MCP (Model Context Protocol) servers for all AI tools";

    servers = {
      filesystem = {
        enable = lib.mkEnableOption "Filesystem MCP server" // {
          default = true;
        };
        allowedPaths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "$HOME"
            "/etc/nixos"
          ];
          description = "Paths allowed for filesystem access";
        };
      };

      git = {
        enable = lib.mkEnableOption "Git MCP server" // {
          default = true;
        };
      };

      playwright = {
        enable = lib.mkEnableOption "Playwright MCP server for browser automation" // {
          default = true;
        };
        browser = lib.mkOption {
          type = lib.types.enum [
            "chrome"
            "firefox"
            "webkit"
            "msedge"
          ];
          default = "chrome";
          description = "Browser to use for Playwright automation";
        };
        capabilities = lib.mkOption {
          type = lib.types.listOf (
            lib.types.enum [
              "vision"
              "pdf"
            ]
          );
          default = [ ];
          description = "Additional capabilities to enable (vision, pdf)";
        };
        headless = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Run browser in headless mode";
        };
        device = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Device to emulate";
        };
        viewportSize = lib.mkOption {
          type = lib.types.str;
          default = "1280x720";
          description = "Browser viewport size in pixels";
        };
        userAgent = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Custom user agent string";
        };
        timeoutAction = lib.mkOption {
          type = lib.types.int;
          default = 5000;
          description = "Action timeout in milliseconds";
        };
        timeoutNavigation = lib.mkOption {
          type = lib.types.int;
          default = 60000;
          description = "Navigation timeout in milliseconds";
        };
        ignoreHttpsErrors = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Ignore HTTPS certificate errors";
        };
        blockServiceWorkers = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Block service workers";
        };
        saveTrace = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Save Playwright trace for debugging";
        };
        saveVideo = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Save video recording";
        };
        grantPermissions = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Permissions to grant";
        };
      };

      puppeteer = {
        enable = lib.mkEnableOption "Puppeteer MCP server (deprecated, use Playwright)" // {
          default = false;
        };
      };

      fetch = {
        enable = lib.mkEnableOption "Fetch MCP server for web content" // {
          default = true;
        };
      };

      context7 = {
        enable = lib.mkEnableOption "Context7 MCP server for documentation" // {
          default = true;
        };
        apiKeyFile = lib.mkOption {
          type = lib.types.path;
          default = "/run/agenix/context7-api-key";
          description = "Path to file containing Context7 API key (agenix secret)";
        };
      };

      grep-app = {
        enable = lib.mkEnableOption "Grep.app MCP server for code search" // {
          default = false;
        };
      };

      brave-search = {
        enable = lib.mkEnableOption "Brave Search MCP server" // {
          default = false;
        };
        apiKey = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Brave Search API key";
        };
      };

      chrome-devtools = {
        enable = lib.mkEnableOption "Chrome DevTools MCP server" // {
          default = true;
        };
      };

      github = {
        enable = lib.mkEnableOption "GitHub MCP server" // {
          default = false;
        };
        apiKey = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "GitHub API token";
        };
      };

      kubernetes = {
        enable = lib.mkEnableOption "Kubernetes MCP server for cluster management" // {
          default = false;
        };
        kubeconfig = lib.mkOption {
          type = lib.types.path;
          default = "";
          description = "Path to kubeconfig file";
        };
      };

      github-actions = {
        enable = lib.mkEnableOption "GitHub Actions MCP server for CI/CD automation" // {
          default = false;
        };
      };

      terraform = {
        enable = lib.mkEnableOption "Terraform MCP server for IaC automation" // {
          default = false;
        };
      };

      ansible = {
        enable = lib.mkEnableOption "Ansible MCP server for configuration management" // {
          default = false;
        };
      };

      n8n = {
        enable = lib.mkEnableOption "n8n workflow automation MCP server" // {
          default = false;
        };
        url = lib.mkOption {
          type = lib.types.str;
          default = "http://localhost:5678";
          description = "n8n instance URL";
        };
      };

      computer-use = {
        enable = lib.mkEnableOption "Computer use MCP server for desktop automation" // {
          default = false;
        };
        platform = lib.mkOption {
          type = lib.types.enum [
            "windows"
            "macos"
            "linux"
          ];
          default = "linux";
          description = "Operating system platform";
        };
      };

      exa = {
        enable = lib.mkEnableOption "Exa web search MCP server" // {
          default = false;
        };
        apiKey = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Exa API key";
        };
      };

      google-drive = {
        enable = lib.mkEnableOption "Google Drive MCP server for cloud storage" // {
          default = false;
        };
      };

      lightpanda = {
        enable = lib.mkEnableOption "LightPanda headless browser MCP server (9x faster than Chrome)" // {
          default = true;
        };
        obeyRobots = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Respect robots.txt when crawling";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        nodejs_22
        (lib.optionalString (lib.hasAttr "uv" pkgs) uv)
      ]
      ++ registryPackages
      ++ lib.optionals cfg.servers.playwright.enable [
        playwright-mcp
        (pkgs.writeShellScriptBin "mcp-playwright" ''
          set -euo pipefail
          if [ -z "''${PWMCP_PROFILES_DIR_FOR_TEST:-}" ]; then
            export PWMCP_PROFILES_DIR_FOR_TEST="$PWD/.pwmcp-profiles"
            echo "[playwright] Using profile directory: $PWMCP_PROFILES_DIR_FOR_TEST"
          fi
          args=()
          args+=(--browser "${cfg.servers.playwright.browser}")
          ${lib.concatStringsSep "\n" (
            map (cap: "args+=(--caps ${cap})") cfg.servers.playwright.capabilities
          )}
          ${lib.optionalString cfg.servers.playwright.headless "args+=(--headless)"}
          ${lib.optionalString (
            cfg.servers.playwright.device != ""
          ) "args+=(--device \"${cfg.servers.playwright.device}\")"}
          args+=(--viewport-size "${cfg.servers.playwright.viewportSize}")
          ${lib.optionalString (
            cfg.servers.playwright.userAgent != ""
          ) "args+=(--user-agent \"${cfg.servers.playwright.userAgent}\")"}
          args+=(--timeout-action "${toString cfg.servers.playwright.timeoutAction}")
          args+=(--timeout-navigation "${toString cfg.servers.playwright.timeoutNavigation}")
          ${lib.optionalString cfg.servers.playwright.ignoreHttpsErrors "args+=(--ignore-https-errors)"}
          ${lib.optionalString cfg.servers.playwright.blockServiceWorkers "args+=(--block-service-workers)"}
          ${lib.optionalString cfg.servers.playwright.saveTrace "args+=(--save-trace)"}
          ${lib.optionalString (
            cfg.servers.playwright.saveVideo != ""
          ) "args+=(--save-video \"${cfg.servers.playwright.saveVideo}\")"}
          ${lib.optionalString (
            cfg.servers.playwright.grantPermissions != [ ]
          ) "args+=(--grant-permissions ${lib.concatStringsSep " " cfg.servers.playwright.grantPermissions})"}
          exec ${pkgs.playwright-mcp}/bin/mcp-server-playwright "''${args[@]}" "$@"
        '')
        (pkgs.writeShellScriptBin "mcp-playwright-chrome" ''
          exec mcp-playwright --browser chrome "$@"
        '')
        (pkgs.writeShellScriptBin "mcp-playwright-firefox" ''
          exec mcp-playwright --browser firefox "$@"
        '')
        (pkgs.writeShellScriptBin "mcp-playwright-webkit" ''
          exec mcp-playwright --browser webkit "$@"
        '')
        (pkgs.writeShellScriptBin "mcp-playwright-headless" ''
          exec mcp-playwright --headless "$@"
        '')
        (pkgs.writeShellScriptBin "mcp-playwright-vision" ''
          exec mcp-playwright --caps vision "$@"
        '')
      ]
      ++ [
        (mkNpmMcpServer {
          name = "context7";
          package = "@upstash/context7-mcp";
          env = {
            CONTEXT7_API_KEY_FILE = toString cfg.servers.context7.apiKeyFile;
          };
        })
      ]
      ++ [
        (mkNpmMcpServer {
          name = "brave-search";
          package = "@modelcontextprotocol/server-brave-search";
          env = lib.optionalAttrs (cfg.servers.brave-search.apiKey != "") (
            lib.listToAttrs [{
              name = "BRAVE_API_KEY";
              value = cfg.servers.brave-search.apiKey;
            }]
          );
        })
      ]
      ++ [
        (mkNpmMcpServer {
          name = "github";
          package = "@modelcontextprotocol/server-github";
          env = lib.optionalAttrs (cfg.servers.github.apiKey != "") {
            GITHUB_API_TOKEN = cfg.servers.github.apiKey;
          };
        })
      ]
      ++ [
        (pkgs.writeShellScriptBin "mcp-gateway-bridge" ''
          exec ${pkgs.python3}/bin/python3 /etc/nixos/scripts/mcp-gateway-bridge "$@"
        '')
      ]
      ++ lib.optional cfg.servers.lightpanda.enable (
        pkgs.writeShellScriptBin "mcp-lightpanda" ''
          exec /opt/lightpanda/lightpanda mcp \
            ${lib.optionalString cfg.servers.lightpanda.obeyRobots "--obey-robots"} \
            "$@"
        ''
      );

    programs.nix-ld.enable = lib.mkDefault true;

    environment.etc."mcp-servers/README.md".text = ''
      MCP servers configured for: OpenCode, Qwen, Kimi,
      | Server | Type | Purpose |
      |--------|------|---------|
      | filesystem | STDIO | Local filesystem access |
      | git | STDIO | Git operations |
      | playwright | STDIO | Browser automation (Nix-provided browsers) |
      | fetch | STDIO | Web fetching |
      | context7 | STDIO | Documentation search |
      | chrome-devtools | STDIO | Chrome debugging |
      | gateway | Bridge | HTTP→stdio proxy to AI Inference Gateway |
      | lightpanda | STDIO | Headless browser (9x faster than Chrome) |
      Servers are generated from the shared registry at
      modules/services/mcp-server-registry.nix. Adding a new server
      requires only adding an entry to the registry.
    '';
  };
}
