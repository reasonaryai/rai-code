<p align="center">
  <picture>
    <source media="(prefers-reduced-motion: reduce) and (prefers-color-scheme: dark)" srcset="assets/logo-rai-white.png">
    <source media="(prefers-reduced-motion: reduce)" srcset="assets/logo-rai-dark.png">
    <source media="(prefers-color-scheme: dark)" type="image/webp" srcset="assets/logo-rai-animated-white.webp">
    <source type="image/webp" srcset="assets/logo-rai-animated-dark.webp">
    <img src="assets/logo-rai-animated.gif" alt="RAI Code" width="640">
  </picture>
</p>

<p align="center">
  <strong>English</strong> · <a href="README.vi.md">Tiếng Việt</a> · <a href="https://code.reasonary.ai/docs">Docs</a>
</p>

**Reasonary AI Code** — a terminal-based AI coding agent with full tool access.

[![Release](https://img.shields.io/github/v/release/reasonaryai/rai-code?label=latest)](https://github.com/reasonaryai/rai-code/releases)
[![License](https://img.shields.io/badge/license-Proprietary-blue)](LICENSE.md)

RAI is an AI coding assistant that runs in your terminal. It connects to LLMs and gives them tools to read, write, and execute code — supporting multiple providers and integrating with LSPs for code intelligence.

---

## Features

- **Multi-Model** — choose from a wide range of LLMs or add your own via OpenAI- or Anthropic-compatible APIs
- **Flexible** — switch LLMs mid-session while preserving context
- **Session-Based** — maintain multiple work sessions and contexts per project
- **LSP-Enhanced** — RAI uses LSPs for additional context, just like you do
- **Extensible** — add capabilities via MCPs (`http`, `stdio`, and `sse`), agent skills, hooks, and custom commands
- **Background Terminals** — builds/tests run while the agent continues independent work. Use `/bt` to view running jobs and output; `/stop` stops only this session’s background jobs. Chat runtimes receive completion observations automatically; Reasonary Responses uses explicit job reads.
- **Headless Runner** — run RAI non-interactively for CI/CD, super-agents, and scripted workflows
- **Reasoning Control** — steer effort levels or thinking with one key (`ctrl+e`) or one CLI flag (`--reasoning`), with automatic clamping to each model's capabilities
- **Cost-Aware Output** — every headless run reports token usage and estimated USD cost in its result
- **Cross-Platform** — macOS, Linux, Windows (PowerShell & WSL), FreeBSD, OpenBSD, NetBSD

---

## Installation

### Via curl (macOS / Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.sh | bash
```

### Via PowerShell (Windows)

```powershell
irm https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.ps1 | iex
```

### Via CMD (Windows)

```cmd
powershell -c "irm https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.ps1 | iex"
```

The installers ask separately whether to install ripgrep for search and the
browser testing bundle, listing every managed component and its pinned version.
Choose Yes, No, or Install later (the default). No suppresses automatic prompts;
Install later asks in the TUI when a tool needs the missing dependency.
Unattended runs never download missing runtimes without explicit approval. Install them later with `rai ripgrep install` and
`rai browser install`. For scripted setup, use `--with-runtimes` or
`--without-runtimes` with `install.sh`, or `-WithRuntimes` / `-WithoutRuntimes`
with `install.ps1`. Use `rai ripgrep path` to inspect the search executable.

### Manual download

Pre-built binaries for all platforms: [GitHub Releases](https://github.com/reasonaryai/rai-code/releases)

SHA256 checksums are included with every release. Installer scripts automatically verify the checksum.

---

## Quick Start

```bash
# Start interactive session
rai

# One-shot prompt (non-interactive)
rai run "Explain this codebase to me"
```

On first run, RAI walks you through provider setup. Press <kbd>alt+m</kbd> at any time to open the model picker, choose your provider, and paste your API key.

---

## Reasonary AI: Auker and API keys

Create an API key at [Reasonary AI keys](https://superagent.reasonary.ai/keys)
to use Auker. Your RAI account login is separate: **model requests require this
API key**.

Two catalog entries distinguish the APIs (both use the same API key):

| RAI model ID | API | Agent loop |
|---|---|---|
| `auker` | Chat Completions | RAI's standard local agent loop and modes |
| `auker-1.0` | Responses | Reasonary Agent (RA), with server sub-agent activity |

For Chat Completions, RAI maps the local alias `auker` to the API's model ID `auker-1.0`.

### Interactive setup

1. Start `rai` and complete the account sign-in if prompted.
2. On first launch, choose **Reasonary AI → Auker 1.0** in the model panel.
   Reasonary AI appears first, with its create-key URL directly below the provider name.
   Later, open this panel with **Alt+M** (or the model command in the palette).
3. If no API key is configured, RAI opens
   [Create API keys](https://superagent.reasonary.ai/keys) in your browser.
   Sign in on that website, create a key, and copy it.
4. Return to RAI, paste the key into the masked API-key field, and press Enter
   to validate it. Press Enter again to save the key and select the model.
   If the browser did not open, use the URL shown in the panel.

The key is saved through the same global configuration flow as other API-key
providers. Subsequent launches reuse it. Selecting `auker-1.0` activates
**Reasonary Agent (RA)** mode. To use another mode, select a model that supports it.

### Headless commands

Create a key on the same [keys page](https://superagent.reasonary.ai/keys),
then sign in to your RAI account with `rai login` before running these commands
from the project directory. Both interactive and headless use require account
sign-in; `REASONARY_AI_API_KEY` authenticates model API requests and does not
replace RAI login. CI must have a valid RAI sign-in credential provisioned.

```bash
# Sign in to your RAI account first (required for UI and headless).
rai login

# Bash / Zsh: supply the key to this command only.
REASONARY_AI_API_KEY='YOUR_API_KEY' rai run --model auker-1.0 \
  "Inspect this project, fix the failing tests, and verify the changes."

# Chat Completions with the standard RAI agent loop.
REASONARY_AI_API_KEY='YOUR_API_KEY' rai run --model auker \
  "Inspect this project, fix the failing tests, and verify the changes."

# JSONL streaming output for benchmark collection.
REASONARY_AI_API_KEY='YOUR_API_KEY' rai run --model auker-1.0 \
  --output-format json "Explain this project's architecture." > result.jsonl

# Or export once for several runs.
export REASONARY_AI_API_KEY='YOUR_API_KEY'
rai run --model auker-1.0 "Review this project without modifying files."
```

Use `rai/auker-1.0` if another configured provider has the same model ID.
`KEY=value && rai run ...` does not export a new shell variable to RAI;
use the inline assignment or `export` form above. The old
`REASONARY_API_KEY` variable belongs to the legacy chat proxy and is not the
Responses API credential.

```powershell
# PowerShell
$env:REASONARY_AI_API_KEY = 'YOUR_API_KEY'
rai run --model auker-1.0 --output-format json "Explain this project."
```

Headless runs use RAI's normal automatic permission approval. With
`RAI_CLIENT_SERVER=1`, provide the key to the **`rai serve` process** as well:
that process makes model requests. Invalid or revoked keys are rejected by the
API; account login does not replace them.

### Streaming activity

Auker streams sub-agent status, tool activity and answer text. Expand a
sub-agent to inspect its reported activity and local tool results. Thinking
and worker model details are displayed only when the API supplies them.

## Other providers and API keys

RAI's provider and model catalog updates from [models.dev](https://models.dev).
Open the model picker with **Alt+M** to see the providers and models available
in your installed version. The examples below are **not an exhaustive list**
of supported providers; catalog availability and model capabilities vary.

Choose a provider in the picker and paste its API key, or use the environment
variable documented by that provider. Common examples:

| Provider | Environment variable |
|----------|----------------------|
| OpenAI | `OPENAI_API_KEY` |
| Anthropic | `ANTHROPIC_API_KEY` |
| Google Gemini | `GEMINI_API_KEY` |
| OpenRouter | `OPENROUTER_API_KEY` |

For endpoints outside the catalog, see [Custom Providers](#custom-providers).
[Local models](#local-models) are also supported. Model capabilities determine
which RAI features are available; a catalog entry does not imply support for
every API feature.

## Agent Runner (Headless / Non-Interactive)

RAI can run headlessly — perfect for super-agents, CI/CD pipelines, and scripted workflows. In headless mode, all permissions are automatically approved and interactive-only tools are disabled.

### `rai run` — Single prompt

```bash
# Basic prompt
rai run "Fix the lint errors in this project"

# Pipe input from stdin
curl https://code.reasonary.ai | rai run "Summarize this website"

# Read from a file
rai run "What is this code doing?" < code.go

# Redirect output to a file
rai run "Generate a README" > README.md

# Run in quiet mode (no spinner)
rai run --quiet "Generate test stubs for all packages"

# Run in verbose mode (show internal logs)
rai run --verbose "Debug the failing integration test"
```

### Model selection

```bash
# Use a specific large model
rai run --model "Claude Opus 4.1" "Design the architecture"

# Use a specific small model (for tool-to-agent routing)
rai run --small-model "Claude Haiku 4.1" "Review this diff"

# Override both
rai run --model "gpt-5.2" --small-model "gpt-oss-120b" "Refactor this module"
```

### Reasoning control

Super-agents can steer the model's reasoning with one flag — an effort level or a thinking toggle:

```bash
# Request an effort level (clamped to the model's supported levels)
rai run --reasoning high "Design the architecture"

# Disable reasoning
rai run --reasoning none "Quick factual question"

# Toggle thinking on/off (models without effort levels)
rai run --reasoning on "Solve this step by step"
```

Effort requests are **clamped** to the closest supported level of the actual
model — `--reasoning low` on a model that only supports `[high, max]` uses
`high`, and the clamp is reported in the result. Requests the model cannot
satisfy at all (effort on a toggle-only model, thinking on an effort model,
reasoning on a non-reasoning model) fail with a clear error so super-agents
never get silent behavior changes.

In interactive mode, <kbd>ctrl+e</kbd> cycles the reasoning control: effort
models advance through their levels, toggle-only models flip thinking.

### Structured JSONL output

For super-agents and CI/CD, use `--output-format json` for JSONL streaming:

```bash
# JSONL streaming (one JSON object per line)
rai run --output-format json "Explain the architecture"

# Pipe to file for later processing
rai run --output-format json "Generate tests" > result.jsonl
```

Each line is a standalone JSON object:

```jsonl
{"type":"thinking","text":"Analyzing the codebase..."}
{"type":"text","text":"Here's the overview..."}
{"type":"tool_use","id":"t1","name":"bash","input":{"command":"ls"}}
{"type":"tool_result","tool_use_id":"t1","tool_name":"bash","output":"...","is_error":false}
{"type":"result","session_id":"ses_xxx","status":"completed","usage":{"input_tokens":14965,"output_tokens":3},"cost_usd":0.00001904,"model_id":"deepseek-v4-flash","provider_id":"deepseek","duration_ms":949}
```

| Event type | Description |
|-----------|-------------|
| `text` | Coalesced assistant text |
| `thinking` | Coalesced reasoning block |
| `tool_use` | Tool invocation with parsed JSON input |
| `tool_result` | Tool execution result |
| `error` | Error event |
| `result` | Terminal event with session_id |

The `result` event carries a usage/cost summary for super-agents to report
back accurate figures: `usage` (`input_tokens`/`output_tokens`), `cost_usd`
(estimated from model.dev pricing), `model_id`/`provider_id`, `duration_ms`,
and `warning` (e.g. reasoning effort clamps). Text mode prints the same
summary as a footer line:

```
── 14978 in / 47 out, $0.000015, 1.5s · deepseek-v4-flash ──
```

Text/thinking deltas are coalesced. Tool calls pass through one-for-one.

### Inline settings override

Override any config value at runtime via `--settings` (highest precedence, above all file-based config):

```bash
# Override permission mode
rai run --settings '{"permission_mode":"accept_all"}' "Refactor this module"

# Enable debug logging for this run
rai run --settings '{"options":{"debug":true}}' "Debug the failing test"
```

### Custom system prompt

Inject persona or policy instructions into the model's system prompt via `--append-system-prompt`:

```bash
# Persona injection
rai run --append-system-prompt "You are a senior Rust engineer. Be terse." "Review this PR"

# Policy enforcement
rai run --append-system-prompt "Never modify *.env files. Always use conventional commits." "Refactor auth"
```

### Session management

Sessions persist between runs. Use session flags to continue conversations:

```bash
# Create a new session (returns session ID on stderr)
rai run --session-name "refactor-auth" "Start refactoring the auth module"
# # session: ses_abc123

# Continue a specific session by ID
rai run --resume ses_abc123 "Continue the refactoring"

# Continue the most recent session
rai run --continue "Pick up where we left off"
rai run -C "Short flag for continue"

# List all sessions
rai sessions
```

### Session ID in output

Headless runs print the session ID to **stderr** before the agent output begins:

```
# session: ses_abc123

(agent output on stdout...)
```

Super-agents can capture the session ID from stderr for later continuation:
```bash
SESSION_ID=$(rai run --session-name "ci-review" "Review this PR" 2>&1 | grep '^# session:' | awk '{print $3}')
# ... do other work ...
rai run --resume "$SESSION_ID" "Apply the fix you suggested"
```

### Exit codes

- **0** — Success (agent completed the task)
- **>0** — Error (check stderr for details)

### Agent-as-a-Tool for Super-Agents

RAI is designed to be invoked programmatically by a **super-agent** (another AI running in a parent process):

```bash
# Super-agent calls RAI as a sub-agent for code generation
rai run --model "Claude Haiku 4.1" --quiet "Fix the type errors in src/auth/login.ts"

# Super-agent pipes diff context
git diff HEAD~1 | rai run --quiet "Review this diff for security issues"

# Super-agent chains multiple sessions
SESSION=$(rai run --session-name "ci-fix" --quiet "Fix the failing tests" 2>&1 | tail -1 | awk '{print $NF}')
rai run --resume "$SESSION" --quiet "Did that resolve the CI failure?"
```

### How it works

1. `rai run` starts the agent in non-interactive mode
2. Interactive-only tools (question prompts) are disabled
3. All permissions are auto-approved — no human-in-the-loop
4. Agent output streams to stdout; session metadata to stderr
5. The process exits with the agent's completion status

### Security model

In headless mode, **all permissions are auto-approved**. The agent executes autonomously.

For **interactive mode** (`rai` without `run`), RAI offers fine-grained permission control:

| Mode | Behavior |
|------|----------|
| `AcceptEdits` | Auto-approve edit/write tools. Ask for everything else |
| `AcceptAll` | Auto-approve everything. No prompts |
| `Prompt` | Ask for every action |

Set via <kbd>ctrl+p</kbd> in interactive mode, or configure in `rai.json`:

```json
{
  "options": {
    "permission_mode": "accept_edits"
  }
}
```

You can also allowlist specific tools:

```json
{
  "permissions": {
    "allowed_tools": ["view", "ls", "grep", "edit"]
  }
}
```

---

## Configuration

RAI runs great with no configuration. Customization is stored as JSON:

```json
{
  "option-name": "value",
  "another-option": ["array", "of", "values"]
}
```

### Priority (highest to lowest)

1. `.rai.json` (hidden project config)
2. `rai.json` (visible project config)
3. `~/.rai/rai.json` (global config)

Application data is stored at:
- **Unix**: `~/.local/share/rai/`
- **Windows**: `%LOCALAPPDATA%\rai\`

You can override locations via `RAI_GLOBAL_CONFIG` and `RAI_GLOBAL_DATA`.

### Global context files

RAI automatically includes two files for cross-project instructions:
- `~/.rai/RAI.md` — RAI-specific rules
- `~/.rai/AGENTS.md` — generic instructions shared with other coding tools

Customize paths:
```json
{
  "options": {
    "global_context_paths": [
      "~/path/to/custom/file.md",
      "/full/path/to/folder/"
    ]
  }
}
```

### Ignoring files

RAI respects `.gitignore` by default. Create a `.raiignore` file (same syntax as `.gitignore`) to exclude additional files from context.

### Disabling built-in tools

```json
{
  "options": {
    "disabled_tools": ["bash", "sourcegraph"]
  }
}
```

### Disabling skills

```json
{
  "options": {
    "disabled_skills": ["rai-config"]
  }
}
```

---

## LSP Integration

RAI can use LSPs for code intelligence (diagnostics, references, completions):

```json
{
  "lsp": {
    "gopls": { "command": "gopls" },
    "rust-analyzer": { "command": "rust-analyzer" },
    "typescript": {
      "command": "typescript-language-server",
      "args": ["--stdio"]
    },
    "nix": { "command": "nil" }
  }
}
```

RAI auto-discovers LSP servers based on project root markers (e.g., `go.mod` → gopls, `Cargo.toml` → rust-analyzer).

---

## MCP Servers

RAI supports Model Context Protocol (MCP) servers through `stdio`, `http`, and `sse` transports.

Shell-style expansion (`$VAR`, `${VAR:-default}`, `$(command)`) works in `command`, `args`, `env`, `headers`, and `url`:

```json
{
  "mcp": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"],
      "timeout": 120
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "timeout": 120,
      "headers": {
        "Authorization": "Bearer $GH_PAT"
      },
      "disabled_tools": ["create_issue"]
    },
    "streaming": {
      "type": "sse",
      "url": "https://example.com/mcp/sse",
      "headers": {
        "API-Key": "$(echo $API_KEY)"
      }
    }
  }
}
```

> **Security note:** `rai.json` is trusted code. Any `$(...)` in it runs at load time with your shell's privileges. Don't launch RAI in a directory whose `rai.json` you haven't reviewed.

---

## Hooks

Hooks run shell commands before tool execution. Define in `rai.json`:

```json
{
  "hooks": {
    "write": [
      { "command": "gofumpt -w {{.Path}}" }
    ],
    "bash": [
      {
        "command": "./scripts/guard.sh {{.Command}}",
        "timeout": "5s"
      }
    ]
  }
}
```

For details, see [hooks documentation](./docs/hooks/).

---

## Agent Skills

RAI supports the [Agent Skills](https://agentskills.io) open standard. Skills are folders containing a `SKILL.md` file:

```bash
# Global skills
mkdir -p ~/.rai/skills

# Project skills
mkdir -p .rai/skills
```

RAI discovers skills from (priority order, highest first):

**Global:**
- `~/.rai/skills/`
- `~/.agents/skills/`
- `~/.claude/skills/`
- `~/.cursor/skills/`
- `~/.codex/skills/`

**Project:**
- `.rai/skills/`
- `.agents/skills/`
- `.claude/skills/`
- `.cursor/skills/`
- `.codex/skills/`

Additional paths via `options.skills_paths`.

### User-invocable skills

Add `user-invocable: true` to the skill's YAML frontmatter to make it available from the command palette:

```yaml
---
name: my-skill
description: Review a pull request for common issues
user-invocable: true
---
```

### Getting started

```bash
mkdir -p ~/.rai/skills
cd ~/.rai/skills
git clone https://github.com/anthropics/skills.git _temp
mv _temp/skills/* . && rm -rf _temp
```

---

## Custom Commands

Commands are reusable prompts discovered from:

```
~/.rai/commands/    ← global
.rai/commands/      ← project
```

Create a command:
```markdown
# Review PR
You are a code reviewer. Analyze the diff for bugs, security issues,
and code smells. Suggest improvements and highlight good patterns.
```

Invoke from the command palette (<kbd>ctrl+p</kbd>).

---

## Logging

Logs are stored in `.rai/logs/rai.log` relative to the project:

```bash
# Last 1000 lines
rai logs

# Last 500 lines
rai logs --tail 500

# Follow in real time
rai logs --follow
```

Enable debug logging:
```json
{ "options": { "debug": true, "debug_lsp": true } }
```

---

## Custom Providers

### OpenAI-compatible

```json
{
  "providers": {
    "deepseek": {
      "type": "openai-compat",
      "base_url": "https://api.deepseek.com/v1",
      "api_key": "$DEEPSEEK_API_KEY",
      "models": [
        {
          "id": "deepseek-chat",
          "name": "Deepseek V3",
          "cost_per_1m_in": 0.27,
          "cost_per_1m_out": 1.1,
          "cost_per_1m_in_cached": 0.07,
          "context_window": 64000,
          "default_max_tokens": 5000
        }
      ]
    }
  }
}
```

### Anthropic-compatible

```json
{
  "providers": {
    "custom-anthropic": {
      "type": "anthropic",
      "base_url": "https://api.anthropic.com/v1",
      "api_key": "$ANTHROPIC_API_KEY",
      "models": [
        {
          "id": "claude-sonnet-4-20250514",
          "name": "Claude Sonnet 4",
          "cost_per_1m_in": 3,
          "cost_per_1m_out": 15,
          "context_window": 200000,
          "default_max_tokens": 50000,
          "can_reason": true,
          "supports_attachments": true
        }
      ]
    }
  }
}
```

### Local models

RAI auto-discovers models from Ollama, llama.cpp, LM Studio, LiteLLM, and OMLX:

```json
{
  "providers": {
    "ollama": {
      "type": "ollama",
      "base_url": "http://localhost:11434/v1/"
    }
  }
}
```

---

## Provider auto-updates

By default, RAI updates its provider/model catalog from [models.dev](https://models.dev). Disable with:

```json
{ "options": { "disable_provider_auto_update": true } }
```

Or: `export RAI_DISABLE_PROVIDER_AUTO_UPDATE=1`

Manually update:
```bash
rai update-providers                # from models.dev
rai update-providers /path/to/providers.json  # models.dev-compatible JSON
```

---

## Metrics

RAI records pseudonymous usage metrics (device hash, no prompts/responses collected). Opt out:

```bash
export RAI_DISABLE_METRICS=1
```

Or configure: `{ "options": { "disable_metrics": true } }`

RAI also respects `DO_NOT_TRACK=1`.

---

## Shell completions

```bash
# Bash:   source <(rai completion bash)
# Zsh:    source <(rai completion zsh)
# Fish:   rai completion fish | source
# PowerShell: rai completion powershell | Out-String | Invoke-Expression
```

---

## Attribution

By default, RAI adds attribution to Git commits and PRs. Customize:

```json
{
  "options": {
    "attribution": {
      "trailer_style": "co-authored-by",
      "generated_with": true
    }
  }
}
```

- `assisted-by` — `Assisted-by: RAI:[ModelID]`
- `co-authored-by` — `Co-Authored-By: RAI <rai@reasonary.ai>`
- `none` — No attribution
- `generated_with` — `Generated with RAI` line in commits/PRs

---

## Clipboard

| OS | Tool |
|----|------|
| Windows, macOS | Native |
| Linux+Wayland | `wl-copy`, `wl-paste` |
| Linux+X11 | `xclip` or `xsel` |

---

## License

[Proprietary license](LICENSE.md). Copyright Reasonary AI Corp. All rights reserved.
