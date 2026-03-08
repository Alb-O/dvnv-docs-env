# Docs Base Devenv

Reusable documentation environment for polyrepo setups using `devenv` v2.

## Includes

- Treefmt: enabled with `mdformat`
- Git hooks: pre-commit `treefmt` and `typos` hooks enabled
- Scripts: `fmt`, `fmt-check`, `spellcheck`, `spellcheck-fix`, `ci`
- Generates `devenv.local.yaml` (via `env-local-overrides`)

## Use

```yaml
inputs:
  env-docs:
    url: github:Alb-O/env-docs
    flake: false
imports:
  - env-docs
```

## Consumer treefmt overrides

Consumers can extend the shared docs formatting by adding extra programs under `treefmt.config`.
This merges with `env-docs` defaults (for example, `mdformat` stays enabled):

```nix
{
  treefmt.config.programs.taplo.enable = true;
}
```
