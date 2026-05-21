"""Runtime contract tests for Pi-native skill guidance."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def test_runtime_contract_validator_passes() -> None:
    scripts_dir = Path(__file__).resolve().parents[1]
    result = subprocess.run(
        [sys.executable, "validate_runtime_contract.py"],
        cwd=scripts_dir,
        text=True,
        capture_output=True,
        check=False,
    )

    assert result.returncode == 0, result.stdout + result.stderr
