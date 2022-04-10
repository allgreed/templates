let
  nixpkgs = builtins.fetchGit {
    # 2022-04-10
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "4762fba469e2baa82f983b262e2c06ac2fdaae67";
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  };
  pkgs = import nixpkgs { config = {}; };
in
pkgs.mkShell {
  buildInputs =
  with pkgs;
  [
    git
    gnumake
  ];
}
