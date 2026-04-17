{
  description = "MCP (Model Context Protocol) server registry and NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosModules.default = import ./mcp-servers.nix;

      nixosModules.registry = import ./mcp-server-registry.nix;
    };
}
