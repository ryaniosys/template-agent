# Pydantic Config Validation Pattern

**Problem:** Agent configs loaded from YAML are untyped dicts. Missing keys, wrong types, and invalid paths surface as runtime errors deep in skill execution -- not at load time.

**Solution:** Validate merged config through a Pydantic model at load time. Fail fast with clear errors.

## Pattern

```python
"""
Config loader: config.local.yaml (overrides) + config.template.yaml (defaults).
Deep merge nested dicts; lists replaced wholesale. Pydantic validates at load time.
"""
from __future__ import annotations

from pathlib import Path

import yaml
from pydantic import BaseModel, field_validator

_REPO_ROOT = Path(__file__).resolve().parents[2]  # adjust depth as needed
_TEMPLATE = _REPO_ROOT / "config.template.yaml"
_LOCAL = _REPO_ROOT / "config.local.yaml"


class MyConfig(BaseModel):
    some_path: str
    some_setting: int = 42

    @field_validator("some_path")
    @classmethod
    def expand_home(cls, v: str) -> str:
        return str(Path(v).expanduser())


def _deep_merge(base: dict, override: dict) -> dict:
    """Deep merge override into base. Lists replaced, dicts merged recursively."""
    result = base.copy()
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = _deep_merge(result[key], value)
        else:
            result[key] = value
    return result


def load_config() -> MyConfig:
    """Load and validate config. Raises on missing/invalid config."""
    if not _TEMPLATE.exists():
        raise FileNotFoundError(f"Config template not found: {_TEMPLATE}")

    with open(_TEMPLATE) as f:
        base = yaml.safe_load(f)

    section = base.get("my_section", {})

    if _LOCAL.exists():
        with open(_LOCAL) as f:
            local = yaml.safe_load(f) or {}
        section = _deep_merge(section, local.get("my_section", {}))

    return MyConfig(**section)
```

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Deep merge (not replace) | Users override one key without repeating the whole config |
| Lists replaced wholesale | Appending creates confusing duplicates; replace is predictable |
| Pydantic at load time | Catches typos, wrong types, missing keys before any work starts |
| `field_validator` for paths | `~/` expansion happens once at validation, not scattered through code |
| Template as fallback | `config.local.yaml` is gitignored; template provides sane defaults |

## Dependencies

```bash
uv add pydantic pyyaml
```

## Gotcha: `.env` files with `export` prefix

When reading `.env` files from other repos (e.g., forwarding API keys), watch out for `export KEY=val` format. Naive `line.startswith("KEY=")` parsing will miss these. Use `"KEY=" in line` and split on the key name instead:

```python
# Wrong
if line.startswith("MY_API_KEY="):
    return line.split("=", 1)[1]

# Right
if "MY_API_KEY=" in line and not line.startswith("#"):
    return line.split("MY_API_KEY=", 1)[1].strip().strip("'\"")
```

## First used in

- `cso-agent` -- coaching transcript pipeline config (`tools/coaching/config.py`)
