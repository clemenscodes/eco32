{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          eco32 = import ./default.nix {inherit pkgs;};
        })
      ];
    };
  in {
    packages = {
      ${system} = {
        default = pkgs.eco32;
        inherit (pkgs) eco32;
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.stdenvNoCC.mkDerivation {
          name = "eco32-shell";
          nativeBuildInputs = with pkgs; [
            pkg-config
          ];
          buildInputs = with pkgs; [
            gnumake
            gcc14
            bison
            flex
            ncurses
            libuuid
            verilog
            xorg.libX11
            xterm
          ];
        };
      };
    };
  };
}
