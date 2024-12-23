let
  pkgs = import <nixpkgs> { };
in
{
  #sunvox = pkgs.callPackage ./src/sunvox.nix { };
  #pixilang = pkgs.callPackage ./src/pixilang.nix { };
  #ocenaudio = pkgs.callPackage ./src/ocenaudio.nix { };

}