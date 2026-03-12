{
  pkgs,
  config,
  lib,
  options,
  ...
}:

let
  cfg = config.docsEnv;
  treefmtBin = lib.getExe config.treefmt.config.build.wrapper;
  typosBin = lib.getExe pkgs.typos;
  typosToml = pkgs.formats.toml { };
  resolveFromRoot =
    path:
    let
      pathString = toString path;
    in
    if lib.hasPrefix "/" pathString then pathString else "${config.devenv.root}/${pathString}";
  typosLocalConfigPath = resolveFromRoot cfg.typos.localConfigPath;
  typosLocalConfig =
    if builtins.pathExists typosLocalConfigPath then
      builtins.fromTOML (builtins.readFile typosLocalConfigPath)
    else
      { };
  # Keep one generated config path for both scripts and hooks so repos can own a
  # normal `typos.toml` today, while we still have room to layer in managed
  # defaults later without changing the consumer workflow.
  typosConfigPath = typosToml.generate "typos-config.toml" (
    lib.recursiveUpdate cfg.typos.managedConfig typosLocalConfig
  );
  mdformatPackage = pkgs.mdformat.withPlugins (
    ps: with ps; [
      mdformat-gfm
      mdformat-frontmatter
      mdformat-footnote
    ]
  );
in
{
  options.docsEnv.typos = {
    localConfigPath = lib.mkOption {
      type = lib.types.oneOf [
        lib.types.str
        lib.types.path
      ];
      default = "typos.toml";
      description = "Repo-local typos config merged over docsEnv.typos.managedConfig.";
    };

    managedConfig = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Managed typos config merged first, before the repo-local typos.toml override.";
    };
  };

  config = lib.mkMerge [
    {
      treefmt = {
        enable = lib.mkDefault true;
        config.programs.nixfmt.enable = lib.mkDefault true;
        config.programs.yamlfmt.enable = lib.mkDefault true;
        config.settings.formatter.mdformat = {
          command = lib.getExe mdformatPackage;
          options = [ "--number" ];
          includes = [ "*.md" ];
        };
      };

      git-hooks = lib.mkIf config.treefmt.enable {
        hooks = {
          treefmt.enable = lib.mkDefault true;
          typos = {
            enable = lib.mkDefault true;
            entry = lib.mkForce "${typosBin} --config ${typosConfigPath} --force-exclude";
          };
        };
      };

      packages = [
        pkgs.just
        pkgs.typos
      ];

      scripts = {
        fmt.exec = lib.mkDefault treefmtBin;
        fmt-check.exec = lib.mkDefault "${treefmtBin} --fail-on-change";
        spellcheck.exec = lib.mkDefault "${typosBin} --config ${typosConfigPath}";
        spellcheck-fix.exec = lib.mkDefault "${typosBin} --config ${typosConfigPath} -w";
        ci.exec = lib.mkDefault ''
          set -euo pipefail
          fmt-check
          spellcheck
        '';
      };

      outputs.typos_config = typosConfigPath;

      enterTest = ''
        set -euo pipefail
        treefmt --version
        typos --version
        fmt-check
        spellcheck
      '';
    }
    (lib.optionalAttrs (options ? instructions && options.instructions ? instructions) {
      instructions.instructions = lib.mkAfter [ (builtins.readFile ./AGENTS.md) ];
    })
  ];
}
