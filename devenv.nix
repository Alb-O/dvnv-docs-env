{ pkgs, config, lib, ... }:

let
  treefmtBin = lib.getExe config.treefmt.config.build.wrapper;
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
        packageOverrides.treefmt = config.treefmt.config.build.wrapper;
        settings.formatters = builtins.attrValues config.treefmt.config.build.programs;
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
