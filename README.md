# Docs Base Devenv

Reusable documentation environment for polyrepo setups using `devenv` v2.

This base is intended for repositories that need:

- shared Markdown formatting defaults
- pre-commit formatting and spelling checks

## Includes

- Treefmt: enabled with `mdformat`
- Git hooks: pre-commit `treefmt` and `typos` hooks enabled
- Scripts: `fmt`, `fmt-check`, `spellcheck`, `spellcheck-fix`, `ci`

## Use from another repo

```yaml
inputs:
  nixpkgs:
    url: github:cachix/devenv-nixpkgs/rolling
  env-docs:
    url: github:Alb-O/env-docs
    flake: false
imports:
  - env-docs
```

Then run:

```bash
devenv test
```

## Consumer treefmt overrides

Consumers can extend the shared docs formatting by adding extra programs under `treefmt.config`.
This merges with `env-docs` defaults (for example, `mdformat` stays enabled):

```nix
{
  treefmt.config.programs.taplo.enable = true;
}
```
