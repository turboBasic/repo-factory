import os
import subprocess
from pathlib import Path

from jinja2 import Template

base_sha = os.environ["BASE_SHA"]
head_sha = os.environ["HEAD_SHA"]
pr_number = os.environ["PR_NUMBER"]
repo = os.environ["REPO"]

# Each commit message is separated by a NUL byte to handle multi-line bodies.
result = subprocess.run(
    ["git", "log", "--format=%B%x00", f"{base_sha}..{head_sha}"],
    capture_output=True,
    text=True,
    check=True,
)
commits = [c.strip() for c in result.stdout.split("\x00") if c.strip()]

subjects = []
change_items = []
for commit in commits:
    lines = commit.splitlines()
    subject = lines[0] if lines else ""
    subjects.append(subject)
    body_lines = [ln.strip() for ln in lines[1:] if ln.strip()]
    if body_lines:
        change_items.append(f"- **{subject}**\n\n  " + "\n\n  ".join(body_lines))
    else:
        change_items.append(f"- {subject}")

description = (
    "\n".join(f"- {s}" for s in subjects) if subjects else "<!-- Briefly describe what this PR does and why. -->"
)
changes = "\n\n".join(change_items) if change_items else "<!-- List the main changes. -->\n\n- Change 1"

with Path(".github/PULL_REQUEST_TEMPLATE.md").open() as f:
    body = Template(f.read()).render(description=description, changes=changes)

subprocess.run(
    [
        "gh",
        "api",
        f"repos/{repo}/pulls/{pr_number}",
        "--method",
        "PATCH",
        "--field",
        f"body={body}",
    ],
    check=True,
)
