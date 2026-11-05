# RAI Code changelog

Release notes for published RAI Code versions, newest first.

<!-- Release maintainers: this is the canonical, public-safe changelog. Add a
published version as "## vX.Y.Z — YYYY-MM-DD", followed by Added, Improved,
Fixed, or Breaking changes sections where applicable. Do not list unreleased
work as shipped. The release sync copies this file to reasonaryai/rai-code, where
the documentation website reads it. Dates are GitHub publication dates in UTC. This changelog starts at v0.7.0;
its initial notes were verified against the v0.7.0 source tag, because the
original mirror release did not include detailed change notes. -->

## v0.8.0 — 2026-11-05

### Added

- **Vision fallback for text-only models.** Browser and terminal screenshots
  and local images are described by a vision-capable model when the active
  model cannot accept images. `options.image_fallback` selects `auto` (the
  cheapest vision model of the same provider), `off`, or a pinned
  `<provider>/<model>`; `/vision` edits it from the TUI. The description is
  labelled second-hand and billed to the session.
- **Progressive tool discovery and context controls.** Tool activation is
  persisted per session and mode, with opt-in native search, versioned guides,
  historical retrieval, observation batching, and request diagnostics.
  Read-only tool calls in one response now run in parallel behind a per-session
  write gate.
- **Context-budget notices** give the agent visibility into available context
  and upcoming automatic compaction.
- **Auker workflow controls.** Coordinators and workers share explicit model
  and mode bindings, a task ledger, successor scoping to unaccepted items, and
  budget feedback when a worker exhausts its steps. Server agents call local
  tools without a discovery round trip, including calls written as DSML text,
  and each attempt records the server execution mode.
- **Sessions survive editor crashes.** The runtime runs in its own systemd
  scope (or a `setsid` fallback), detached background jobs keep their
  workspace alive, and a later build attaches to a running runtime instead of
  failing. `rai server --idle-timeout` exits an auto-spawned runtime once no
  workspace depends on it.
- **Per-request usage and cost.** Every completed provider request (steps,
  sub-agents, titles, compaction) is booked in a ledger; `rai run` summaries
  and JSON output report cumulative session usage, with context-tier pricing,
  cache rates, and sub-agent cost rolled into the run.
- **Provider onboarding** accepts additional request headers, including
  workspace identifiers, and distinguishes missing-header errors from invalid
  keys. CheaperInference model discovery is available in the picker.
- **Design and review skills** add focused Hallmark studies and composition
  guidance, scoped reviews with a design profile, security guidance, and
  checkpoints that survive an interrupted review. The design gate opens the
  prototype and collects captures when the runtime can show images, and
  reports a source-only review as PARTIAL otherwise.
- `grep` and `fetch` keep matches and bounded excerpts when a result exceeds a
  tool limit instead of failing the turn.

### Improved

- Compaction sizes segments in bytes, summarizes them in parallel (up to four),
  keeps the recent tail on routed models, and retries a length-rejected
  `/compact` in bounded segments. Oversized requests recover through the same
  path.
- Bash write detection observes what a command actually changed; it follows
  `cd`, `git -C`, and `xargs`, permits scratch writes outside the project, and
  tells the agent when a delete needs the user instead of a file tool.
- The verify gate no longer counts demo hosting or git-ignored scratch as
  product writes, and a commit or `/tmp` cleanup no longer expires a passing
  review and verify.
- Auker workers receive their core tool schemas up front and resolve habitual
  aliases such as `read` to `view`; the coordinator sees sizing feedback and
  the mode each attempt ran in.
- The chat keeps its scroll position while sub-agents stream or finish; clicks
  during streaming act on the item pressed, word-navigation keys follow the
  platform convention, the key hint bar starts collapsed, and prompts typed
  while a session is busy stay queued.
- Compact summaries render as "Compacted in Ns" across the server/client
  boundary, and a background job observation is delivered once instead of on
  every later step.
- Review and verification follow revision-aware recovery, reuse evidence for
  unchanged code, and refuse to repeat a passing review or verify on the same
  revision.
- Planning, implementation, and testing instructions require acceptance
  criteria and a named test per rule; a builder may not weaken, delete, or
  skip a test to get green, and interrupted reviews keep their checkpoint.
- Base instructions, modes, and built-in skills use more focused research,
  discovery, and delegation guidance with less repeated context.

### Changed

- Installers, `rai update`, and the public mirror now use
  `reasonaryai/rai-code` instead of `wiiscale/rai-pub`. The `VERSION` pointer
  is written by one shared script, ignores prereleases, and only moves forward.
- Generated workspace `rai.json` files for automatic LSP setup are added to
  `.gitignore`; existing tracked configurations are left unchanged.
- Terminal branding uses the shared RAI Code icon across the banner, exit
  screen, READMEs, and notifications; `rai -v` stays text-only.
- When `image_fallback` is `auto` and the provider has no vision model, the
  existing text note is kept. Auker image input remains opt-in behind
  `RAI_REASONARY_IMAGE_INPUT=1`.

### Fixed

- Trimming a long history no longer leaves assistant messages with only
  reasoning, which strict OpenAI-compatible endpoints reject. A first run with
  no credential reaches the sign-in screen instead of failing to start the
  runtime, and forwarded service events are no longer lost.
- Auker: task creation no longer fails on a concurrent ledger write, purposes
  that differ only in case are accepted, an expired response ID is dropped
  instead of retried, local LSP execution is repaired, and a successor
  receives only the items without valid PASS evidence.
- The UI no longer jumps when a sub-agent streams or finishes, a streaming
  click no longer opens the newest item, and "back to bottom" no longer stops
  inside an expanded sub-agent.
- Accounted usage includes cache and reasoning correctly, Gemini's running
  stream totals are counted once, and run cost is the session delta including
  sub-agents, titles, and compaction.
- Nested `.gitignore` negations and `.raiignore` whitelists are honored by
  `grep` on both backends, and partial coverage is reported instead of failing
  silently.
- A title request whose two configured models resolve to the same wire model
  is no longer sent twice, and a truncated title falls back only when the
  request would actually differ.
- A credential missing from the OS keychain is read from the private file, so
  a failed keychain write no longer forces another sign-in.
- Headless parent runs no longer treat a child session's completion as their
  own.
- The bundled Auker model points at the production endpoint in every build;
  `REASONARY_AI_RESPONSES_URL` still overrides it at runtime.
- Plan creation returns the actual timestamped path to the agent and displays
  it in the terminal, and sub-agent mode resolution honors explicitly selected
  modes and discovered specialist names. Context recovery and terminal
  rendering for narrow lists, images, and diff views are improved.

### Breaking changes

- `rai update` and the installers now read releases from
  `reasonaryai/rai-code`. Installs that pinned the old `wiiscale/rai-pub`
  mirror should update through the new location; `VERSION` only moves forward,
  so re-syncing an older tag cannot roll it back.

## v0.7.0 — 2026-10-19

This is the starting version for the RAI Code changelog.

### Added

- Auker is available in the Reasonary AI model catalog, replacing its earlier coming-soon entry.
- **Auker (Chat Completions)** runs through RAI's local agent loop and tools.
- **Auker 1.0 (Responses)** uses the Reasonary Agent runtime, with server agent orchestration and local tool execution in RAI.

### Setup

Model requests require a Reasonary AI model API key. Signing in to your RAI account and configuring model access are separate steps.

[View release and downloads](https://github.com/reasonaryai/rai-code/releases/tag/v0.7.0)
