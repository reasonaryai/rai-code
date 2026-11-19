# RAI Code changelog

Release notes for published RAI Code versions, newest first.

<!-- Release maintainers: this is the canonical, public-safe changelog. Add a
published version as "## vX.Y.Z — YYYY-MM-DD", followed by Added, Improved,
Fixed, or Breaking changes sections where applicable. Do not list unreleased
work as shipped. The release sync copies this file to reasonaryai/rai-code, where
the documentation website reads it. Dates are GitHub publication dates in UTC. This changelog starts at v0.7.0;
its initial notes were verified against the v0.7.0 source tag, because the
original mirror release did not include detailed change notes. -->

## v0.9.4 — 2026-11-19

### Added

- **Auto permission mode.** The default **Accept edits** mode is now **Auto**: ordinary
  work (edits, builds, tests, linters, local git, installs inside the project, localhost
  servers) runs without a question and RAI asks only when it detects a dangerous call:
  deleting or writing outside the workspace, `.git` hooks, shell rc files and RAI config,
  credential reads, force pushes and other shared-history changes, publishing, privilege
  and disk commands, persistence, killing foreign processes, download-and-run, cloud
  metadata and private-network URLs, and commands whose effect cannot be seen. The
  categories, the `permissions.auto` settings (a project config can only tighten them)
  and the denial tracking (Auto falls back to asking after 3 denials in a row or 20 in
  total) are in [docs/AUTO_MODE.md](docs/AUTO_MODE.md). `accept_edits` and `auto-edit`
  keep working as Auto; `--permission-mode=auto` is accepted. A denied or deferred call
  now tells the model what was detected and not to retry or work around it. Sub-agents
  follow their session's mode and a dangerous call from one is deferred for review. The
  **Auto-approve all** label is now **Full Access**. Edits outside the workspace
  and `fetch` of cloud-metadata or private addresses (including names that resolve to them) no longer run silently. Auto's only automatic scratch folder outside the project is `<temp>/rai-<uid>` (the `TMPDIR` of bash commands); and a project script, Makefile target, npm/yarn/pnpm script or just recipe a command runs is read and checked line by line. The optional
  model-based classifier is not part of this release.

- **Folder trust.** A folder's own config files (`rai.json`, `.rai.json`,
  `.rai/rai.json`, `.rai/mcp.json`, including ones in parent folders up to the git
  root) can declare commands RAI would start: MCP stdio servers, plugin packages,
  hooks and custom LSP commands. They no longer run without your consent. The first
  time you open a folder that declares any, RAI lists every command verbatim with the
  file it comes from and asks: Trust all, Choose each, Don't trust (continue without
  them) or Quit. The decision is stored in your user data directory, per folder and
  per command: editing or adding a command asks again, about that command only.
  Remote MCP servers (HTTP/SSE) and your own global config are unaffected. For
  scripts, `rai run --trust` or `RAI_TRUST_PROJECT=1` opts in for one run; without it
  the skipped commands are printed to stderr. `rai trust` / `rai untrust` change the
  decision and `rai doctor` shows it. Full access mode never grants trust.

### Improved

- **Auto mode is harder to talk around.** Closing the gaps found by comparing it with Claude
  Code's auto mode: inline interpreter code (`python3 -c`, heredocs, `node -e`, `perl -e`,
  `ruby -e`, `awk`, `sed ...e`, `trap`) is read for commands, file writes, network and
  credentials; credential reads are caught through relative paths, `cd`, globs, symlinks,
  `/proc/*/environ`, shell histories and environment dumps; a write whose target path is
  built from an unset variable asks; `.vscode/`, `.idea/`, `.husky/`, `.github/workflows/`,
  `.envrc`, `.bashrc` and `.gitconfig` are protected inside the workspace too;
  `PATH`/`LD_PRELOAD`/`GIT_SSH_COMMAND`/`NODE_OPTIONS=--require` style variables,
  download-then-run, `npx`/`uvx`/`pipx run`/`pip install` of packages the project does not
  declare, secrets sent with `curl`, git in a repository outside the workspace and a bare
  `git push` from `main` ask. Allow rules and hook approvals no longer override protected
  paths, credentials or deletes outside the workspace, blanket allow rules (`bash`,
  `bash:python3`, `bash:sh`, `bash:npx`...) are ignored in Auto like Claude Code does, a
  headless `rai run` now denies dangerous calls (with the reason) instead of approving them
  and aborts after the denial limits, and an MCP server's own read-only claim is no longer
  trusted. See [docs/AUTO_MODE.md](docs/AUTO_MODE.md).

- **Auto asks about programs it does not know.** A command used to be ordinary unless it
  matched a danger rule; now it is ordinary only when its programs are on a documented list
  of development tooling (Go, Rust, Node, Python, JVM, C/C++, git, docker, coreutils,
  formatters, linters and so on), workspace executables or functions the command defines. Any
  other program, or one started by a path outside the workspace and system directories, asks
  once (**Allow for session** remembers it). `permissions.auto.known_commands` adds your own
  tools to the list. Formatters, editors and compressors have their file arguments checked as
  writes. See [docs/AUTO_MODE.md](docs/AUTO_MODE.md#known-programs).
- **The code index no longer takes over your home folder, and indexes only your code.** Starting RAI in your home folder (or any folder whose data directory is the global `~/.rai`) used to index everything you own, store it next to your settings and keep a full second copy: gigabytes. The index now stays off there, and in any folder that is not a project (no `.git`, no build file such as `go.mod` or `package.json`), with one short note (`options.knowledge.index: lazy` opts in and indexes on demand), and databases of deleted workspaces are removed after 7 days. The index also used to walk the project's own `.rai` data folder (experiments, worktree copies) and count it as code, which could make it many times the size of the project; it now only reads your project's source files and never `.rai`, `.git`, the data directory, or anything your `.gitignore`/`.raiignore` hide. There is no default size cap: a large codebase is indexed completely (`options.knowledge.max_db_mb` is an opt-in limit, `options.knowledge.max_files` raises the 50000-file scan limit), and a scan that hits the file limit is shown as incomplete in `rai doctor` and the index status. `rai doctor` shows the index sizes and warns for a non-project workspace.
- A project config can no longer set provider endpoints or credentials commands, or
  pre-approve tools, until the folder is trusted.

**Heads-up for existing users:** the first time you open a folder that already has
such commands, RAI asks once.

- **Code mode is named Code again** (`C`; Ask is `A`). Only the name changes:
  Code mode still delegates to parallel sub-agents as before, and `--mode agentic`
  remains an accepted alias of `code`.

- Design workers establish a shared foundation before splitting related screens, and can download real photos with explicit web optimization. Ordinary downloads retain their bytes; optimized results report the saved checksum and preserve originals without overwriting existing files.
- The design phase's self-review is one quick, strictly bounded pass instead of a screenshot test cycle. When the coordinator has no browser, the quick look goes into the design worker's own assignment.
- Review and verification reuse attributable evidence for the unchanged source revision. Optional suggestions do not restart a completed check, and low-risk mechanical changes request the missing local readback before demanding independent workers.
- A new question or correction can steer the active turn after the current tool step. Old to-dos and acceptance records no longer automatically pull a completed answer back into earlier work.
- Large session lists and terminal scrolling remain responsive with bounded activity probes and more precise scrollbar dragging.

### Fixed

- Recoverable tool-call failures start collapsed in chat; click or Space reveals their full details. Errors that stop the turn remain visible.
- Cut-off tool arguments are never executed. Interrupted or incomplete turns retain an explicit status in chat and command output.
- Image budget recovery keeps stored originals and can resend newly read images after a provider rejects an oversized request.
- Tool argument and edit errors give more precise diagnostics. Background dispatch is included in the Agentic Auker tool contract.

## v0.9.3 — 2026-11-14

### Added

- **Send immediately or queue.** While the agent is working, Enter sends your
  message into the running turn once the current tool step finishes, and Tab
  queues it as the next turn. A muted line shows the message is waiting; if the
  turn is interrupted or the runtime is lost the text returns to the composer.
- **The sub-agent session is obvious.** Opening a sub-agent shows a label bar
  with its name and mode, an accent border, a "Sub-agent: name" badge in the
  sidebar, and clearer status icons in the agents list.
- **Duplicate background servers are flagged.** Starting a service lists the ones
  already running and warns when the same server is started again (for example on
  another port), with rules to reuse, fix, and stop services before finishing.
- **The Responses model is shown as Agentic Auker**; the chat model keeps the
  name Auker.
- **Background work is visible and wakes the agent.** The agents panel shows
  elapsed time and token use per agent, the chat shows "Waiting for N background
  agents to finish", and the main agent starts a new turn on its own when
  background jobs or sub-agents finish (a user stop never triggers a wake).
  Background bash accepts `wake_on_output` to wake on a matching line.
- **Job details are live.** Opening a background job shows its status, a running
  clock, its command and an output that follows the tail; `x` stops it from
  there.
- **Attachment chips open and sit in the text.** Ctrl+click opens the file, and
  pasted files and images appear as inline tokens that delete together with
  their chip.
- **Screenshots are reused** when the page, viewport and workspace are
  unchanged; `force: true` takes a fresh one.
- **`rai update [--check]`, `rai resume`, `rai models list`, `rai projects list`,
  `rai config`, `rai login status`** and `rai doctor` sub-views follow common CLI
  conventions. Older spellings keep working and print a hint.
- **Code mode is shown as Agentic** (`Ag`; Ask is `As`). `--mode agentic` works
  on `rai run` and `rai review`.
- **Sub-agents can run in parallel beyond five** (`options.max_parallel_agents`,
  default 16).

### Improved

- **A sub-agent transcript shows its own activity.** Opening a sub-agent that is
  still running shows the Working row with the child's own elapsed time (not the
  main turn's), Esc asks for confirmation and cancels only the child being viewed
  while its siblings keep running, and the row disappears when the child finishes.
- **Model preferences follow the agreed phase table.** Planning, architecture,
  design and visual review, implementation, testing, debugging, review, verify,
  research and docs each prefer an ordered set of models (design and visual review
  prefer DeepSeek V4.1 Flash only; implementation and testing DeepSeek V4.0/V4.1
  Flash then GLM 5.3 Flash). MiniMax M3 is no longer preferred by any phase, and
  writing tests is its own phase, separate from running verification. A preferred
  model the Auker catalog does not offer is skipped, never substituted.
- **Lean or full is a judgment, not a list of cases.** The agent decides by what
  could go wrong and for whom: small, self-contained, low-consequence work is done
  directly and checked once, while wide or sensitive work (auth, secrets, data,
  migrations, money, deployment, unclear requests) keeps the staged workflow with
  independent review and verification. Asking for a "design" or a "build" no longer
  makes a small task large.
- **Fewer needless review and verify rounds.** A turn whose sub-agents changed
  nothing in the workspace, or only touched files RAI or the toolchain maintain
  (`.gitignore` rules for rai.json, `go.sum`, caches), is no longer gated; a
  verify or review worker gets one pass and at most one resume per revision.
- **Run time and tokens on every agents row**, formatted like the turn timer, and
  the main row keeps its time and tokens while a sub-agent is open.
- **Updates work while RAI is open.** On Windows the running executable is
  renamed aside instead of overwritten; elsewhere the new file replaces it
  atomically. One source decides the latest version for manual, automatic and
  scripted installs, and development builds never update themselves.
- **Completion checks cover 19 languages**, and small low-risk changes finish
  with a lighter check instead of a full independent review.
- **Auker routing follows the work.** The phase (research, design, implement,
  review, verify) is detected from the task, also in existing repositories.
- **Replies keep your language**, and the first progress message states whether
  the task takes the lean or the full path.
- **Provider outages are recoverable.** The replacement-model question appears
  for the main agent and for sub-agents, expires after
  `options.replace_model_timeout_minutes`, and the chosen model is used for the
  next prompt. Questions are queued per session and flagged in `/session`.
- **Separate runtimes per project and data directory**, so several terminals no
  longer interfere with each other.
- **Errors are specific.** Server messages such as "data directory already in
  use" are shown instead of a bare status code, and `rai config set` refuses
  values that would make the config unreadable.

### Fixed

- On Windows, edits were refused with "file has not been read yet" right after a
  successful view when the model wrote the path with forward slashes
  (`C:/Users/...`), ending in a loop. Reads are now matched across path spellings.
- A sub-agent resume that also carried name, mode or model fields was refused;
  those fields are ignored and the worker continues.
- A plain comment containing a colon (for example `# Helper: returns 1`) no longer
  triggers the strict completion gate and an independent verification.
- When a turn was continued on a replacement model (or retried), the original
  prompt was sent a second time, which could repeat finished tool calls.
- The "runtime stopped" error now stays visible until the runtime reconnects.
- A workflow that could not be accepted no longer loops for many minutes; it ends
  with a blocked report, and repositories without tests converge.
- A crash when many agents started at once.
- A lost runtime is reported instead of leaving `rai run` or the UI waiting
  forever.
- `rai projects` no longer lists the runtime's own state directory.

### Privacy

- The third-party usage telemetry was removed. Error reports to RAI stay off
  unless `options.enable_error_reports` is set.

## v0.9.2 — 2026-11-12

### Added

- **Worktrees are first-class.** `rai worktree add` creates a checkout seeded
  with its own `.rai` configuration, while list, remove, merge and prune report,
  remove, merge a branch back after showing its diffstat, and drop records whose
  directory is gone; all but prune take `--json`. `/worktree` adds each
  worktree's session activity, starts a headless agent inside one, and reopens
  rai in the selected worktree with the flags it was launched with.
- **Native workers run isolated.** Auker workers can be given their own
  worktree, ownership is recorded in Git's administrative directory, and the
  session remembers its execution root so a later resume continues in the same
  checkout.
- **The agents panel shows running sub-agents.** A roster between the prompt and
  the help bar lists every in-flight agent with its live activity; enter opens
  its transcript, `x` stops one, `ctrl+k` stops all, and `ctrl+x` focuses the
  panel. It yields space to the prompt on short terminals.
- **The user query stays pinned.** The question behind the visible response
  remains above the transcript while you scroll.
- **Usage reports durable totals.** The Usage tab shows the session's token and
  cache totals from the ledger, not just the current context window.
- **MCP results that are clipped stay readable** instead of being reported as
  gone.
- **Install-all consent is remembered per workspace**, and the install-all
  choice sits first when a workspace has several runtimes to install.

### Improved

- **One engineering contract in every prompt.** Modes and skills share the
  research-backed behavior rules, and every mode shows visible work-recap
  checkpoints.
- **Completion gates are scoped.** The gate counts resumed review and
  verification evidence, reuses resumed receipts, and exempts bounded
  presentation-only edits.
- **Auker routing is explicit.** `prefer_models` and `exclude_models` are
  validated and shared by both transports, routing requires a verified API key,
  and the Responses reasoning effort is fixed at medium instead of exposing a
  control.
- **Worker identity and intent survive recovery.** A resumed worker keeps its
  pinned identity and delegated intent, a task that outgrew a worker's budget is
  reported to the coordinator, and feedback after recovery needs fresh
  acceptance.
- **Context handling is cheaper.** Connected-server instructions moved out of the
  system prefix, a rewound turn recovers instead of staying compacted off, and
  compaction budgets retained history beside turn overhead.
- **Release downloads retry** transient and interrupted transfers instead of
  failing the update.
- Interface polish: shared selection styles, sidebar mode colors, an aligned
  routing legend, model display names in sub-agent summaries, a composer left
  edge that stays put across sessions, copyable diagnostics, responsive session
  navigation, and collapsed tool discovery.
- `rai -v` shows the mascot again.

### Fixed

- Google usage counts reasoning once: the adapter folds thoughts into the
  candidate output, so token totals and cost no longer double by default for
  responses that report both.
- The prompt cache prefix is no longer rewritten on every request.
- Compaction keeps room for the sections that matter, segments local overflow
  with background observations, and keeps resumed worker previews bounded.
- Dependency installs surface consent failures and npm root causes, and keep
  installer failures with bounded logs.
- Sub-agent history is discoverable after completion, a user stop is
  distinguished from a failure, child navigation and duplicate names stay
  apart, and local sub-agent calls render as one line.
- Windows startup probes keep onboarding connected instead of blocking the
  workspace.
- A directory walk no longer feeds non-UTF-8 files into the prompt.
- Knowledge-graph visibility is restored, and sharing a published knowledge
  index reports ready.

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

- **The verification gate is `off` by default.** RAI no longer nudges a turn
  that changes files to run review and verification: the agent instructions still
  ask for them in code phases, but nothing at runtime pushes the agent. This also
  stops the Agentic Auker completion feedback from continuing a finished turn.
  Set `verify_gate` to `soft` (one nudge) or `strict` to restore the runtime gate.

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
