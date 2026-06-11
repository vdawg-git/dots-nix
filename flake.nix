{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-25.05";

    moo.url = "github:vdawg-git/moo";
    moo.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    self,
    stable,
    ...
  } @ inputs: let
    # This is a helper that helps us construct flake outputs for multiple systems at once.
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      # "aarch64-linux"
    ];
    pkgsForEach = forAllSystems (
      system:
        import nixpkgs {
          localSystem.system = system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = ["electron-39.8.10"];
          overlays = [
            (final: prev: {
              stablePkgs = import stable {
                localSystem.system = final.stdenv.hostPlatform.system;
                config.allowUnfree = true;
                config.permittedInsecurePackages = ["electron-39.8.10"];
              };
            })
          ];
        }
    );
  in {
    nixosConfigurations = {
      # XXX: If desired, the host construction can be extracted into a helper command that takes
      # a hostname, the special args, and extraModules to append. That way we can construct the nixosSystem args dynamically, per-host. That is for another time, though.
      legion = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        pkgs = pkgsForEach."x86_64-linux";
        modules = [
          # Get host-specific configuration from hosts/<hostname>/host.nix
          # This is not a convention, but it's nice to have :)
          ./hosts/legion/host.nix

          # Blanket-import all shared modules in ./modules
          # The alternative to this is getting them one-by-one.
          ./modules/system

          # Extra module as not every device has bluetooth
          ./modules/system/bluetooth.nix

          {nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";}
        ];
      };

      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        pkgs = pkgsForEach."x86_64-linux";
        modules = [
          ./hosts/swordfish/host.nix
          ./modules/system
          ./modules/system/bluetooth.nix

          {nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";}
        ];
      };

      swordfish = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        pkgs = pkgsForEach."x86_64-linux";
        modules = [
          ./hosts/swordfish/host.nix
          ./modules/system
          ./modules/system/bluetooth.nix
          {nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";}
        ];
      };

      yf19 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        pkgs = pkgsForEach."x86_64-linux";
        modules = [
          ./hosts/yf19/host.nix
          ./modules/system
          {nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";}
        ];
      };
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://zed.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
