{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/?rev=nixos-25.05";
    home-manager.url = "github:nix-community/home-manager?rev=release-25.05";
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs = {
    nixpkgs,
    home-manager,
    self,
    ...
  } @ inputs: let
    # This is a helper that helps us construct flake outputs for multiple systems at once.
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"];
    pkgsForEach = forAllSystems (system:
      import nixpkgs {
        localSystem.system = system;
        overlays = [self.overlays.default];
      });

    userNames = [
      "vdawg"
      "ck"
    ];
  in {
    nixosConfigurations = {
      # XXX: If desired, the host construction can be extracted into a helper command that takes
      # a hostname, the special args, and extraModules to append. That way we can construct the
      # nixosSystem args dynamically, per-host. That is for another time, though.
      legion = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs userNames;};
        modules = [
          # Get host-specific configuration from hosts/<hostname>/host.nix
          # This is not a convention, but it's nice to have :)
          ./hosts/legion/host.nix

          # Blanket-import all shared modules in ./modules
          # The alternative to this is getting them one-by-one.
          ./modules/system
        ];
      };

      /*
      # TODO: Uncomment when those hosts have real configurations, or import Legion's host
      # config in them to satisfy base assertions for, e.g., filesystems.
      swordfish = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs userNames;};
        modules = [
          ./modules/system

          # Add a dummy nixpkgs.hostPlatform to each host that lacks a hardware config
          # so that 'nix flake check' passes. The genereated hardware-configuration.nix
          # already contains the following, so we can omit it when the host has a real
          # config.
          {nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";}
        ];
      };

      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs userNames;};
        modules = [
          ./modules/system
          {nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";}
        ];
      };
      */
    };

    homeConfigurations.

    homeConfigurations =
      nixpkgs.lib.mapAttrs (system: pkgs: {
        "vdawg" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            # Import the home of the 'vdawg' user. The naming choice is
            # not really a convention, but it *is* nice to have.
            ./homes/vdawg/homee.nix
          ];

          # Make sure HM has access to 'inputs' and everything that comes
          # from it.
          extraSpecialArgs = {inherit inputs;};
        };
      })
      pkgsForEach;
  };
}
