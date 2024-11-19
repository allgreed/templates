let
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "76612b17c0ce71689921ca12d9ffdc9c23ce40b2"; # 13-11-2024
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  }) { config = {}; };

  # helpers
  pythonDevPkgs = python-packages: devDeps python-packages ++ appDeps python-packages;
  pythonAppPkgs = python-packages: appDeps python-packages;
  devPython = pythonCore.withPackages pythonDevPkgs;
  appPython = pythonCore.withPackages pythonAppPkgs;

  pythonCore = pkgs.python311;
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
      ruff
      ruff-lsp

      podman
    ];
  };
}
