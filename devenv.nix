{ pkgs, config, lib, ... }:

let
  treefmtBin = lib.getExe config.treefmt.config.build.wrapper;
  mdformatPackage = pkgs.mdformat.withPlugins (
    ps: with ps; [
      mdformat-gfm
      mdformat-frontmatter
      mdformat-footnote
    ]
  );
in
{
  treefmt = {
    enable = lib.mkDefault true;
    config.settings.formatter.mdformat = {
      command = lib.getExe mdformatPackage;
      options = [ "--number" ];
      includes = [ "*.md" ];
    };
  };

  git-hooks = lib.mkIf config.treefmt.enable {
    hooks = {
      treefmt.enable = lib.mkDefault true;
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

  instructions.instructions = lib.mkAfter [ (builtins.readFile ./AGENTS.md) ];

  enterTest = ''
    set -euo pipefail
    treefmt --version
    typos --version
    fmt-check
    spellcheck
  '';
}
