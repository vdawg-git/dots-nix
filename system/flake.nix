{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
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
          ./1password.nix
          ./bootloader.nix
          ./configuration.nix
          ./hyprland.nix
          ./keyd.nix
          ./pam.nix
          ./pkgs-base.nix
          ./theme.nix
        ];
      };
    in
    {
      nixosConfigurations.swordfish = default;
      nixosConfigurations.legion = default;
      nixosConfigurations.nixos = default;
    };
}
