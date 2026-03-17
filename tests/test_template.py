"""Integration tests for Copier templates.

Each test class covers one template.  Tests render the template into a
temporary directory via subprocess (mirroring what create_repo.sh does),
then assert on the output without importing the generated code directly —
that keeps the test environment clean and avoids path-manipulation hacks.

Running:
    pytest tests/ -v
"""

import importlib.util
import subprocess
import sys
from pathlib import Path

import pytest

TEMPLATES_DIR = Path(__file__).parent.parent / "templates"


# ── helpers ───────────────────────────────────────────────────────────────────


def copier_copy(template: str, dest: Path, data: dict[str, str]) -> None:
    """Render *template* into *dest* using copier copy with --defaults."""
    cmd = [
        sys.executable,
        "-m",
        "copier",
        "copy",
        "--defaults",
        "--overwrite",
        "--quiet",
    ]
    for key, value in data.items():
        cmd += ["--data", f"{key}={value}"]
    cmd += [str(TEMPLATES_DIR / template), str(dest)]

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(
            f"copier copy failed (exit {result.returncode}):\n"
            f"stdout: {result.stdout}\n"
            f"stderr: {result.stderr}"
        )


# ── python-app template ───────────────────────────────────────────────────────


class TestPythonAppTemplate:
    """Tests for templates/python-app."""

    TEMPLATE = "python-app"
    DATA: dict[str, str] = {
        "project_name": "My Test App",
        "project_slug": "my_test_app",
        "description": "A test application",
        "python_version": "3.12",
    }

    @pytest.fixture(scope="class")
    def generated(self, tmp_path_factory: pytest.TempPathFactory) -> Path:
        """Render the template once per class into a shared temp directory."""
        dest = tmp_path_factory.mktemp("python-app")
        copier_copy(self.TEMPLATE, dest, self.DATA)
        return dest

    # ── file existence ────────────────────────────────────────────────────────

    def test_pyproject_toml_exists(self, generated: Path) -> None:
        assert (generated / "pyproject.toml").is_file()

    def test_readme_exists(self, generated: Path) -> None:
        assert (generated / "README.md").is_file()

    def test_package_init_exists(self, generated: Path) -> None:
        assert (generated / "src" / "my_test_app" / "__init__.py").is_file()

    def test_main_module_exists(self, generated: Path) -> None:
        assert (generated / "src" / "my_test_app" / "main.py").is_file()

    def test_dunder_main_exists(self, generated: Path) -> None:
        assert (generated / "src" / "my_test_app" / "__main__.py").is_file()

    def test_ci_workflow_exists(self, generated: Path) -> None:
        assert (generated / ".github" / "workflows" / "ci.yml").is_file()

    def test_test_file_exists(self, generated: Path) -> None:
        assert (generated / "tests" / "test_import.py").is_file()

    # ── content assertions ────────────────────────────────────────────────────

    def test_package_name_in_pyproject(self, generated: Path) -> None:
        content = (generated / "pyproject.toml").read_text()
        assert 'name = "my_test_app"' in content

    def test_python_version_in_pyproject(self, generated: Path) -> None:
        content = (generated / "pyproject.toml").read_text()
        assert "requires-python" in content
        assert "3.12" in content

    def test_description_in_pyproject(self, generated: Path) -> None:
        content = (generated / "pyproject.toml").read_text()
        assert "A test application" in content

    def test_project_name_in_readme(self, generated: Path) -> None:
        content = (generated / "README.md").read_text()
        assert "My Test App" in content

    def test_project_slug_in_readme(self, generated: Path) -> None:
        content = (generated / "README.md").read_text()
        assert "my_test_app" in content

    def test_no_raw_jinja_in_pyproject(self, generated: Path) -> None:
        """Verify all template variables were rendered (no leftover {{ }})."""
        content = (generated / "pyproject.toml").read_text()
        assert "{{" not in content
        assert "}}" not in content

    def test_no_raw_jinja_in_readme(self, generated: Path) -> None:
        content = (generated / "README.md").read_text()
        assert "{{" not in content
        assert "}}" not in content

    def test_no_raw_jinja_in_main(self, generated: Path) -> None:
        content = (generated / "src" / "my_test_app" / "main.py").read_text()
        assert "{{" not in content
        assert "}}" not in content

    # ── importability ─────────────────────────────────────────────────────────

    def test_package_importable(self, generated: Path) -> None:
        """The generated __init__.py must be loadable by importlib."""
        init_path = generated / "src" / "my_test_app" / "__init__.py"
        spec = importlib.util.spec_from_file_location("my_test_app", init_path)
        assert spec is not None, "Could not create module spec"
        module = importlib.util.module_from_spec(spec)
        assert spec.loader is not None
        spec.loader.exec_module(module)

    # ── generated-project tests ───────────────────────────────────────────────

    def test_generated_pytest_passes(self, generated: Path) -> None:
        """The generated project's own test suite must pass."""
        result = subprocess.run(
            [sys.executable, "-m", "pytest", "tests/", "-q", "--tb=short"],
            cwd=generated,
            capture_output=True,
            text=True,
            env={
                # Inject src/ onto PYTHONPATH so tests run without pip install.
                **__import__("os").environ,
                "PYTHONPATH": str(generated / "src"),
            },
        )
        assert result.returncode == 0, (
            f"Generated project pytest failed:\n{result.stdout}\n{result.stderr}"
        )
