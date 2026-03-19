# Docs Base Devenv

Reusable documentation environment for AgentRoots workspaces using `devenv` v2.

## Includes

- Treefmt: `mdformat`
- Git hooks: pre-commit `typos` hook enabled
- Scripts: `spellcheck`, `spellcheck-fix`, `ci`
- Merged typos config via `outputs.typos_config`
- Generates `devenv.local.yaml` (via `agentroots`)

## Use

```yaml
inputs:
  ar_devenv_base:
    url: github:Alb-O/ar_devenv_base
    flake: false
  ar_docs_env:
    url: github:Alb-O/ar_docs_env
    flake: false
imports:
  - ar_devenv_base
  - ar_docs_env
```

## Consumer treefmt overrides

Consumers can extend the shared docs formatting by adding extra programs under `treefmt.config`.
This composes with the shared `ar_devenv_base` baseline and keeps `ar_docs_env` focused on Markdown formatting:

```nix
{
  treefmt.config.programs.taplo.enable = true;
}
```

## Typos Config

Repos can keep a normal `typos.toml` at the repo root. `ar_docs_env` merges
that file over `docsEnv.typos.managedConfig` and uses the generated effective
config for both:

- `spellcheck` / `spellcheck-fix`
- the pre-commit `typos` hook

No managed defaults are set yet, but the merge path is in place for later.
