{ pkgs, config, lib, ... }:

let
  treefmtBin = lib.getExe config.treefmt.config.build.wrapper;
  treefmtPreCommit = pkgs.writeShellApplication {
    name = "treefmt-pre-commit";
    runtimeInputs = [ pkgs.git ];
    text = ''
      set -euo pipefail

      if (($# == 0)); then
        exit 0
      fi

      # Stage formatter edits so the current commit can succeed in one pass.
      ${treefmtBin} --no-cache "$@"
      git add -- "$@"
    '';
  };
in
{
  treefmt = {
    enable = lib.mkDefault true;
    config.programs.mdformat.enable = lib.mkDefault true;
  };

  git-hooks = lib.mkIf config.treefmt.enable {
    hooks = {
      treefmt = {
        enable = lib.mkDefault true;
        entry = lib.getExe treefmtPreCommit;
        packageOverrides.treefmt = config.treefmt.config.build.wrapper;
        settings = {
          # We apply and stage fixes in-hook instead of failing on first change.
          fail-on-change = false;
          formatters = builtins.attrValues config.treefmt.config.build.programs;
        };
      };
      typos.enable = lib.mkDefault true;
    };
  };

  packages = [
    pkgs.just
    pkgs.typos
  ];

  scripts = {
    fmt.exec = lib.mkDefault treefmtBin;
    fmt-check.exec = lib.mkDefault "${treefmtBin} --fail-on-change";
    spellcheck.exec = lib.mkDefault "typos";
    spellcheck-fix.exec = lib.mkDefault "typos -w";
    ci.exec = lib.mkDefault ''
      set -euo pipefail
      fmt-check
      spellcheck
    '';
  };

  enterTest = ''
    set -euo pipefail
    treefmt --version
    typos --version
    fmt-check
    spellcheck
  '';
}
