let
  pkgs = import <nixpkgs> {};
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      nimPackages.nim
      gtk3
    ];
  }
