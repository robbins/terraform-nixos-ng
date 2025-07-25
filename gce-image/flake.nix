{
  inputs = {
    nixpkgs.url = "github:robbins/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
      pkgs = import nixpkgs { 
        inherit system;
      };
  in
  {
    nixosConfigurations = {
      gce-image = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ 
          ./image-configuration.nix
          "${nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
        ];
      };
    };
  };
}
