{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @inputs :
  let 
	a = 1;

	userNames = ["vdawg" "ck"];
  in
 {
	nixosConfigurations.swordfish = nixpkgs.lib.nixosSystem {
		specialArgs = { inherit inputs userNames; };
		modules = [
			./configuration.nix
			./home.nix
		];
	};


  };
}
