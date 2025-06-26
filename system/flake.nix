{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      userNames = [
        "vdawg"
        "ck"
      ];

      default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs userNames; };
        modules = [
          ./bootloader.nix
          ./configuration.nix
          ./hyprland.nix
          ./keyd.nix

        ];
      };
    in
    {
      nixosConfigurations.swordfish = default;
      nixosConfigurations.legion = default;
      nixosConfigurations.nixos = default;
    };
}
