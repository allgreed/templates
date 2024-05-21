let
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "b8697e57f10292a6165a20f03d2f42920dfaf973"; # 4-03-2024
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  }) { config = {}; };

  # helpers
  pythonDevPkgs = python-packages: devDeps python-packages ++ appDeps python-packages;
  pythonAppPkgs = python-packages: appDeps python-packages;
  devPython = pythonCore.withPackages pythonDevPkgs;
  appPython = pythonCore.withPackages pythonAppPkgs;

  pythonCore = pkgs.python310;
  devDeps = p: with p; [
    ptpython # nicer repl
    pytest
  ];
  appDeps = p: with p; [
    # TODO: deps go here
  ];
in
rec {
  pname = "fillthis";
  version = "0.0.1";
  artifacts = rec {
    app = appPython.pkgs.buildPythonApplication {
      inherit pname version;

      src = builtins.filterSource (path: type:  baseNameOf path != ".git") ./.;

      dependencies = appDeps appPython.pkgs;
      # disable tests while building
      #dontUseSetuptoolsCheck = true;
    };
    container = pkgs.dockerTools.buildLayeredImage {
      name = pname;
      tag = version;

      #created = "now";

      contents = [ appPython app ];

      config = {
        Entrypoint = [
          "${app}/bin/main.py"
        ];
      };
    };
  };
  shell = pkgs.mkShellNoCC {
    buildInputs = with pkgs; [
      git
      gnumake
      devPython
      pyright
      podman
    ];
  };
}
