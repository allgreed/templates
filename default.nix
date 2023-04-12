let
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "3fb8eedc450286d5092e4953118212fa21091b3b"; # 12-04-2022
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  }) { config = {}; };
  pythonPkgs = python-packages: with python-packages; [
    ptpython # nicer repl
  ];
  pythonCore = pkgs.python39;
  myPython = pythonCore.withPackages pythonPkgs;
in
pkgs.mkShell {
  buildInputs =
  with pkgs;
  [
    git
    gnumake
    #myPython
  ];
}
