---
name: terminal-output-fallback
description: "Use when terminal command output is unexpectedly empty (for example only prompt markers like '%' or '❯') despite successful execution. Automatically switch to file-based output capture, read captured output, report results, and clean up temporary files."
---

# Terminal Output Fallback

## Purpose

Provide a reliable workflow when terminal output capture is broken but commands still execute.

## Trigger Signals

- Terminal command returns with no visible stdout or stderr.
- Output repeatedly shows prompt markers only (for example `%` or `❯`).
- Exit code indicates success but expected text is missing.

## Required Workflow

1. Detect suspected capture failure after one quick verification command.
2. Switch to file-based capture for subsequent terminal commands.
3. Execute each command with stdout and stderr redirected to a temporary file.
4. Read the temporary file content using workspace file tools.
5. Report the command result to the user from captured content.
6. Remove temporary files unless the user requests keeping them.

## Command Pattern

```bash
mkdir -p .copilot-capture
{ <command>; printf "\n__EXIT_CODE__:%s\n" "$?"; } > .copilot-capture/<name>.log 2>&1
```

Then read `.copilot-capture/<name>.log` and include important output details in the response.

## Rules

- Do not pretend commands failed if capture is blank; use fallback capture.
- Do not hide command failures; always surface non-zero exit status.
- Keep fallback files short-lived and delete them after reporting.
- Prefer stable, deterministic filenames when multiple captures are needed in one task.
