{ pkgs }:
let 

in
{
  imports = [
    ./nvim { inherit pkgs; }
  ];
}
