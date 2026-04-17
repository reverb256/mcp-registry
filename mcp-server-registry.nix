{ lib }:
let
  servers = {
    filesystem = {
      type = "npm";
      package = "@modelcontextprotocol/server-filesystem";
      args = [
        "/etc/nixos"
        "/home/j_kro"
      ];
    };

    git = {
      type = "uvx";
      package = "mcp-server-git";
      entrypoint = "mcp-server-git";
    };

    fetch = {
      type = "uvx";
      package = "mcp-server-fetch";
      entrypoint = "mcp-server-fetch";
    };

    playwright = {
      type = "custom";
    };

    context7 = {
      type = "npm";
      package = "@upstash/context7-mcp";
      env = {
        CONTEXT7_API_KEY_FILE = "";
      };
    };

    chrome-devtools = {
      type = "npm";
      package = "chrome-devtools-mcp@latest";
    };

    lightpanda = {
      type = "custom";
    };

    gateway = {
      type = "custom";
    };

    puppeteer = {
      type = "npm";
      package = "@modelcontextprotocol/server-puppeteer";
    };

    brave-search = {
      type = "npm";
      package = "@modelcontextprotocol/server-brave-search";
      env = {
        BRAVE_API_KEY = "";
      };
    };

    github = {
      type = "npm";
      package = "@modelcontextprotocol/server-github";
      env = {
        GITHUB_API_TOKEN = "";
      };
    };
  };

  mkCommand = name: "mcp-${name}";
in
{
  inherit servers mkCommand;
}
