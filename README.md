# Docs Base Devenv

Reusable documentation environment for polyrepo setups using `devenv` v2.

## Includes

- Treefmt: enabled with `mdformat`, `nixfmt`, and `yamlfmt`
- Git hooks: pre-commit `treefmt` and `typos` hooks enabled
- Scripts: `fmt`, `fmt-check`, `spellcheck`, `spellcheck-fix`, `ci`
- Merged typos config via `outputs.typos_config`
- Generates `devenv.local.yaml` (via `poly-local-inputs`)

## Use

```yaml
inputs:
  poly-docs-env:
    url: github:Alb-O/poly-docs-env
    flake: false
imports:
  - poly-docs-env
```

## Consumer treefmt overrides

Consumers can extend the shared docs formatting by adding extra programs under `treefmt.config`.
This composes with `poly-docs-env` defaults (for example, `mdformat`, `nixfmt`, and `yamlfmt` stay enabled):

```nix
{
  treefmt.config.programs.taplo.enable = true;
}
```

## Typos Config

Repos can keep a normal `typos.toml` at the repo root. `poly-docs-env` merges
that file over `docsEnv.typos.managedConfig` and uses the generated effective
config for both:

- `spellcheck` / `spellcheck-fix`
- the pre-commit `typos` hook

No managed defaults are set yet, but the merge path is in place for later.
