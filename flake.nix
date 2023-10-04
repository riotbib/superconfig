{
  description = "lassulus superconfig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    astro-nvim.url = "github:AstroNvim/AstroNvim";
    astro-nvim.flake = false;

    clan-core.url = "git+https://git.clan.lol/clan/clan-core";
    # clan-core.url = "git+file:/home/lass/src/clan/clan-core";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";
    clan-core.inputs.flake-parts.follows = "flake-parts";
    clan-core.inputs.disko.follows = "disko";

    stockholm.url = "git+https://cgit.lassul.us/stockholm";
    # stockholm.url = "path:/home/lass/sync/stockholm";
    stockholm.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    # disko.url = "git+file:/home/lass/src/disko/";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, clan-core, ... }:
  let
    clan = clan-core.lib.buildClan {
      directory = self;
      specialArgs.self = self;
      machines = nixpkgs.lib.mapAttrs (machineName: _: {

        imports = [
          ./nixos/machines/${machineName}/physical.nix
          {
            clanCore.machineName = machineName;
            clanCore.secretStore = "password-store";
            krebs.secret.directory = "/etc/secrets";
          }
        ];
      }) (builtins.readDir ./nixos/machines);
    };
  in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [
        ./tools/nvim.nix
        ./tools/astronvim/flake-module.nix

        ./tools/zsh.nix
      ];
      flake.nixosConfigurations = clan.nixosConfigurations;
      flake.clanInternals = clan.clanInternals;
      perSystem = { config, pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          packages = [
            clan-core.packages.${system}.clan-cli
            pkgs.qemu_kvm
          ];
        };
      };
    };
}
