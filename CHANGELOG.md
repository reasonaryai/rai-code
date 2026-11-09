# RAI Code changelog

Release notes for published RAI Code versions, newest first.

<!-- Release maintainers: this is the canonical, public-safe changelog. Add a
published version as "## vX.Y.Z — YYYY-MM-DD", followed by Added, Improved,
Fixed, or Breaking changes sections where applicable. Do not list unreleased
work as shipped. The release sync copies this file to reasonaryai/rai-code, where
the documentation website reads it. Dates are GitHub publication dates in UTC. This changelog starts at v0.7.0;
its initial notes were verified against the v0.7.0 source tag, because the
original mirror release did not include detailed change notes. -->

## v0.9.1 — 2026-11-09

### Added

- **Replacement models when a provider stops.** A turn whose provider cannot
  continue asks before switching, then offers the configured models from other
  providers; the selection is saved as Settings / Config → Replace model and the
  same turn continues from its existing history and completed tool results.

### Improved

- **Transient provider failures are retried inside the step.** Rate limits,
  overloads, 5xx and timeouts back off and retry up to five times for Auker
  models on both transports, while permanent errors still surface immediately.
  Step retries and queued recovery no longer stack, and a failed provider still
  goes through the verification gate.
- **CheaperInference is offered at setup**, with its authenticated catalog
  refreshed as soon as a key is saved.
- **Tool reasons and handoffs follow the user's language**, matching the rest of
  the response.

### Changed

- **The verification gate defaults to `strict`.** A turn that changes files now
  needs current independent review and runtime verification, or explicit skip
  reasons, before it completes. Set `verify_gate` to `soft` for the previous
  single nudge, or `off` to disable the check.

### Fixed

- Pressing y or n in a Yes/No shortcut question submits that answer
  immediately instead of waiting for a second confirmation.
- Model picker groups no longer print provider API-key URLs.

## v0.9.0 — 2026-11-08

### Added

- **Settings is a tabbed panel.** Status, Config, Usage and Stats live in one
  panel, with pointer and keyboard navigation between tabs.
- **Mouse support across the TUI.** Dialogs, question panels, popups and the
  permission picker accept clicks and hover, and the responsive key hints follow
  the active panel.
- **Full Access from the approval dialog.** A permission request offers Allow,
  Allow for Session, Full Access and Deny; Full Access grants the request and
  switches the session to full access.
- **Verified background updates.** A release downloads and verifies its signed
  checksums in the background, shows a restart notice and has a settings
  toggle. Snoozed and skipped releases are honored, and a failed download or
  verification keeps the installed binary.
- **Dependency installs ask first.** Managed runtimes share Yes, No and Install
  later decisions, with versioned manifests and install progress in local and
  remote chat; installer runtime setup is optional.
- **Idle recaps.** Short ephemeral summaries appear before the companion sleeps.
- **60 fps recordings.** Browser and terminal workflows record with paced input
  and a fixed frame rate, including a native terminal WebM export and
  compatible bundled VP8/VP9 codecs.

### Improved

- **Focused tool schemas.** Browser and terminal interaction tools carry
  smaller, purpose-built schemas, core tools configure their runtime policies,
  focused discovery works with legacy validation, and the agent documentation
  explains deferred operations.
- **Composer and transcript polish.** The composer is framed and compact, mode
  badges stay visible while scrolling, working gradients are readable, queued
  prompts are highlighted, selection chevrons are unified, timestamps use
  readable colons, and cursor blinking follows its own timer instead of the
  terminal setting.
- **Sessions.** Busy state is isolated per session, the landing view shows
  background activity, title generation finishes independently with a model
  fallback, internal prompt envelopes are stripped from titles, and the latest
  explicit model choice carries into new sessions.
- **Recaps** summarize only the latest turn as language-aware prose and stay
  visible while you read or compose a draft.
- **Sign-in** completes API-key verification in one submission, replaces a
  pasted key and waits for the clipboard, and retries transient provider
  connection timeouts.
- **Fewer permission prompts.** Trusted reads and local edits, and trusted
  read-only fetches in accept-edit, no longer prompt; MCP read-only approval
  follows the current server contract, and code-mode aliases are refused.
- **The model picker prioritizes Super Agent** and explains switching to a
  bound session.
- **Notifications** alert only for important events while the session is
  unfocused.
- Elapsed time pauses while the agent waits for your input, macOS model
  shortcuts are labelled with Option, and Windows keeps background process
  helpers hidden.
- `rai build-info` carries the diagnostic metadata that used to sit in the CLI.

### Changed

- **The theme picker offers named themes.** Custom palette editing is gone;
  `theme_mode` remains as a legacy fallback when no theme is selected.
- **Approval stays explicit.** The experimental Auto review mode was withdrawn
  before release, so a permission request always offers an explicit choice.
- Repository-wide gofumpt and goimports formatting, and unused module checksums
  pruned for the release toolchain.

### Fixed

- **`rai -u` installs across filesystems.** The updater unpacked the download in
  the system temp directory and renamed it onto the install path, which Linux
  rejects with `invalid cross-device link`; it now stages the binary beside the
  target and swaps it atomically, and refuses to overwrite the running binary
  when staging fails.
- Composer pointer focus, panel spacing and the mascot sleep state.
- Release signing checks validate derived updater target names.
- Repository lint errors and stale UI replay markers.

## v0.8.1 — 2026-11-06

### Fixed

- **Pasting works with native shortcuts.** The editor and the API-key dialog
  accept `ctrl+v`, `ctrl+shift+v`, `cmd+v`/`super+v`, `shift+insert` and `alt+v`,
  and the hint follows the platform (`cmd+v / ctrl+v` on macOS, `ctrl+v / alt+v`
  elsewhere). Select-all, undo and redo also accept the macOS Cmd variants.
- **Clipboard reads in the API-key dialog cannot clobber newer input.** Reads
  are tagged with a request id and a "clipboard unavailable" result is separated
  from a slow terminal, so a late reply never replaces what you typed or
  interrupts verification.
- **The Windows installer verifies the release signature on Windows
  PowerShell 5.1.** 5.1 has no `RSA.ImportFromPem` and often no `openssl`, so
  the installer previously refused to continue. It now decodes the embedded
  public key itself and verifies in-process with .NET (PKCS#1 v1.5 over
  SHA-256); `openssl` and PowerShell 7 keep their paths. The trust chain is
  unchanged: signature, then checksums, then extract.
- **Windows install failures are actionable.** Every phase reports its name
  (`ERROR: <step> failed: <message>`), the temp root falls back to
  `%LOCALAPPDATA%\Temp` when `TMP`/`TEMP` is not writable, a failed probe leaves
  no directory behind, and the guidance names the temp, install and cache
  locations with `TMP`, `TEMP`, `RAI_INSTALL_DIR`, `RAI_CACHE_DIR` and
  `RAI_BROWSER_RUNTIME_DIR`.
- **Installer failures no longer close the shell.** The refusal paths raise
  errors instead of exiting, so `irm … | iex` keeps the session (and the
  message) while `powershell -c` still returns a non-zero code.
- **Windows PowerShell 5.1 no longer prompts a security warning.** Downloads
  pass `-UseBasicParsing` on the Desktop edition, avoiding the IE-engine
  parse prompt.
- **`install.cmd` no longer changes your working directory.** The installer
  directory switch happens inside the PowerShell process, and the bootstrap
  keeps the installer's exit code.

### Added

- **Expand-all hint.** `ctrl+shift+o` / `alt+shift+o` is documented in the
  adaptive key hints.

### Changed

- **READMEs link the documentation site.** The language switcher of all three
  READMEs now points at `code.reasonary.ai/docs`.
- **The README wordmark animates everywhere.** The picture element falls back
  to a looping GIF because GitHub's image proxy does not animate every WebP,
  while the animated WebP sources and the static PNGs for
  `prefers-reduced-motion` are kept. Every mirror list (task, workflow, sync
  guard) now knows the new asset, and the guard fixture includes
  `CHANGELOG.md`.

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
