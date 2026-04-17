# Example: Declaring MCP servers in your NixOS configuration
#
# Add to your configuration.nix or a dedicated module:
#
#   imports = [ path/to/mcp-registry/nixosModules.default ];
#
# Then configure which servers to enable:

{ config, ... }:

{
  services.mcp-servers = {
    enable = true;

    servers.filesystem = {
      enable = true;
      allowedPaths = [ "$HOME" "/etc/nixos" "/data/projects" ];
    };

    servers.git.enable = true;

    servers.playwright = {
      enable = true;
      browser = "chrome";
      headless = false;
      viewportSize = "1280x720";
      timeoutAction = 5000;
      timeoutNavigation = 60000;
    };

    servers.fetch.enable = true;

    servers.context7 = {
      enable = true;
      apiKeyFile = "/run/agenix/context7-api-key";
    };

    servers.lightpanda = {
      enable = true;
      obeyRobots = true;
    };

    servers.chrome-devtools.enable = true;

    # Optional servers (disabled by default):
    # servers.brave-search = {
    #   enable = true;
    #   apiKey = "your-brave-api-key";
    # };
    #
    # servers.github = {
    #   enable = true;
    #   apiKey = "your-github-token";
    # };
    #
    # servers.kubernetes = {
    #   enable = true;
    #   kubeconfig = "/home/user/.kube/config";
    # };
  };
}
