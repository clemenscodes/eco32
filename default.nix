{pkgs ? import <nixpkgs> {}}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "eco32";
  version = "0.29";
  name = "${pname}-${version}";
  src = pkgs.fetchFromGitHub {
    owner = "hgeisse";
    repo = pname;
    rev = "51fcacd84d47231d5e719fc51b9dc2e771c76a40"; # fp branch
    hash = "sha256-Ru7s1DCAzbh0CotDj3uBiq2rw95Qw9yzAYnGo01bOGo=";
  };
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
  ];
  installPhase = ''
    mkdir -p $out
    cp -r build/* $out
  '';
}
