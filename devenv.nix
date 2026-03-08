{ pkgs, config, lib, ... }:

let
  docsAgentsText = if builtins.pathExists ./AGENTS.md
    then builtins.readFile ./AGENTS.md
    else "";
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
    fmt.exec = treefmtBin;
    fmt-check.exec = "${treefmtBin} --fail-on-change";
    spellcheck.exec = "typos";
    spellcheck-fix.exec = "typos -w";
    ci.exec = ''
      set -euo pipefail
      fmt-check
      spellcheck
    '';
  };

  materializer.ownFragments.env-docs = [ docsAgentsText ];
  materializer.mergedFragments = lib.mkAfter [ docsAgentsText ];

  enterTest = ''
    set -euo pipefail
    treefmt --version
    typos --version
    fmt-check
    spellcheck
  '';
}
