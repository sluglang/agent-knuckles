# 🐌 Knuckles

A Slug-native coding agent that inspects, understands, and modifies codebases
through an iterative tool-use loop backed by a local or cloud language model.

Knuckles operates through a small, explicit set of tools — read, edit, run,
grep, commit — and keeps full state in a local SQLite database so sessions
survive crashes and can be resumed.

![Agent Knuckles](docs/agent_knuckles.png)

---

## Features

- **Local sessions** — analyse and edit code, run tests, produce reports
- **GitHub issues** — implement an issue, commit, push, and open a PR automatically
- **PR review** — read a diff and post a structured review via the GitHub API
- **Persistent sessions** — every turn is stored; crashed sessions resume cleanly
- **Auto-test on edit** — run your test suite after every file change
- **Auto-commit safety net** — if you forget to commit before `done`, Knuckles commits for you
- **Smart context window** — old turns are summarised so long sessions stay coherent
- **Task-specific prompts** — different system prompt overlays for local, issue, review, and report modes
- **Revert tool** — undo the last edit to a file and try a different approach

---

## Requirements

- [Slug](https://sluglang.org) — the Slug runtime
- [Ollama](https://ollama.com) or a compatible model endpoint
- A GitHub personal access token (for issue and review commands)

---

## Installation

Clone the repository and configure `slug.toml`:

```bash
git clone https://github.com/sluglang/agent-knuckles
cd knuckles
```

Edit `slug.toml` to set your model and GitHub token:

```toml
[knuckles.agent]
knuckles_model = "llama3"          # or qwen3-coder, deepseek-coder, etc.

[knuckles.github.auth]
github_token = "ghp_your_token_here"
```

---

## Quick start

### Review a local repository

```bash
slug knuckles.slug run \
  --goal "review this codebase and write a description" \
  --repo ./my-project
```

### Fix a GitHub issue

```bash
slug knuckles.slug issue \
  --repo owner/repo \
  --issue 42
```

Knuckles will fetch the issue, clone or use the local repo, create a branch
`knuckles/issue-42-title-slug`, implement the change, run tests, commit, push,
and open a pull request.

### Review a pull request

```bash
slug knuckles.slug review \
  --repo owner/repo \
  --pr 17
```

### Resume a crashed session

```bash
slug knuckles.slug list           # find the session ID
slug knuckles.slug resume --id a3f9c2d1
```

---

## Commands

| Command  | Description                                       |
|----------|---------------------------------------------------|
| `run`    | Start a local agent session with a free-form goal |
| `issue`  | Implement a GitHub issue and open a PR            |
| `review` | Review a GitHub pull request                      |
| `resume` | Resume an existing session by ID                  |
| `list`   | Show all sessions                                 |
| `show`   | Print the full turn-by-turn history of a session  |

---

## Options

| Option    | Default              | Description                                                |
|-----------|----------------------|------------------------------------------------------------|
| `--goal`  | (required for `run`) | Task description                                           |
| `--repo`  | `.`                  | Local path or `owner/repo` to clone                        |
| `--issue` |                      | GitHub issue number                                        |
| `--pr`    |                      | GitHub PR number                                           |
| `--base`  | `main`               | Base branch for opened PRs                                 |
| `--draft` | `false`              | Open PR as draft                                           |
| `--model` | `llama3`             | Ollama model name                                          |
| `--test`  |                      | Command to run after every edit (e.g. `slug test --dir .`) |
| `--mode`  | auto                 | Prompt overlay: `local` \| `issue` \| `review` \| `report` |
| `--db`    | `knuckles.db`        | SQLite database path                                       |

All options can also be set in `slug.toml` via the corresponding `cfg` keys.

---

## Configuration (`slug.toml`)

```toml
[knuckles.agent]
knuckles_model = "llama3"
knuckles_max_turns = 50
knuckles_context = 30
knuckles_slug_spec = "./data/SLUG.ai"
knuckles_manifest = "./data/MANIFEST.ai"

[knuckles.core.tools]
run_timeout_ms = 30000
run_after_edit = "slug test --dir ."   # auto-run tests after every edit

[knuckles.core.format]
knuckles_context_threshold = 30   # compress history after this many turns
knuckles_context_recent = 10   # keep this many turns verbatim

[knuckles.github.auth]
github_token = ""        # GitHub PAT or fine-grained token
github_api_url = "https://api.github.com"

[knuckles.github.repo]
knuckles_workspace = "/tmp/knuckles"   # where repos are cloned

[knuckles.store]
knuckles_db = "./data/knuckles.db"
```

---

## Tools available to the agent

| Tool            | Purpose                                                |
|-----------------|--------------------------------------------------------|
| `read`          | Read a file                                            |
| `list`          | List directory contents                                |
| `find`          | Plain-string search in `.slug` files                   |
| `grep`          | Regex search across all file types                     |
| `write`         | Create or overwrite a file                             |
| `edit`          | Surgical single-occurrence string replacement          |
| `revert`        | Undo the last edit to a file                           |
| `run`           | Run a shell command                                    |
| `git_status`    | Show working tree status                               |
| `git_diff`      | Show unstaged and staged changes                       |
| `git_log`       | Show recent commits                                    |
| `git_commit`    | Stage all changes and commit                           |
| `git_push`      | Push branch to origin                                  |
| `github_review` | Post a PR review (COMMENT / APPROVE / REQUEST_CHANGES) |
| `prompt`        | Ask the developer a question and wait for input        |
| `remember`      | Store a fact that persists across the context window   |
| `diff`          | Show all Knuckles patches applied this session         |
| `done`          | Finish and summarise the task                          |

---

## Project layout

```
knuckles.slug              # CLI entrypoint
slug.toml                  # configuration

knuckles/
  agent.slug               # execution loop
  store.slug               # SQLite session persistence
  core/
    session.slug           # immutable session state model
    parse.slug             # XML action parser
    tools.slug             # tool implementations
    format.slug            # prompt builder and result formatter
  github/
    auth.slug              # GitHub API auth and HTTP helpers
    repo.slug              # clone, branch, commit, push
    issue.slug             # read issues and comments
    pr.slug                # open PRs, read diffs, post reviews

prompts/
  core.md                  # base system prompt (all modes)
  overlay/
    local.md               # local session additions
    issue.md               # git workflow rules and git tools
    review.md              # PR review process and event guidance
    report.md              # written output requirements

db/migrations/
  001__create_kn_sessions.sql
  002__create_kn_turns.sql

data/
  SLUG.ai                  # Slug language reference for the model
  MANIFEST.ai              # stdlib module manifest for the model
  knuckles.db              # session database (generated)
```

---

## How it works

Knuckles runs an iterative loop:

```
session
  → build prompt (core.md + overlay + SLUG.ai + MANIFEST.ai + facts)
  → call model (Ollama)
  → parse XML tool call from response
  → execute tool
  → persist turn to kn_turns table
  → save session state to kn_sessions table
  → repeat until done
```

Each turn is stored individually in SQLite so a crash at any point leaves a
fully recoverable state. Session history older than the context threshold is
automatically compressed into a structured summary so the model stays coherent
across long sessions without losing awareness of what has already been done.

For issue sessions, Knuckles automatically commits any uncommitted file changes
when `done` is called, so changes are never silently lost even if the model
forgets to call `git_commit` explicitly.

---

## Prompt customisation

System prompts live in `prompts/` as plain markdown files. You can edit them
directly without touching any Slug code — changes take effect on the next turn.
The `{{goal}}`, `{{repoRoot}}`, and `{{facts}}` placeholders are substituted
at runtime.

To add a new task mode, create `prompts/overlay/mymode.md` and pass
`--mode mymode` on the command line.

---

## Session database

Knuckles stores all session state in a local SQLite database (`knuckles.db`
by default). Two tables:

**`kn_sessions`** — one row per session with goal, repo, turn count, status,
and a JSON snapshot of non-history state (facts, patches, results).

**`kn_turns`** — one row per conversation turn with role, content, turn number,
and timestamp. History is stored here rather than in the session JSON so the
database grows linearly and sessions can be inspected with standard SQL tools.

```sql
-- find all active sessions
SELECT id, goal, turn
FROM kn_sessions
WHERE done = 0;

-- read the history of a session
SELECT turn_num, role, content
FROM kn_turns
WHERE session_id = 'a3f9c2d1...'
ORDER BY turn_num, id;
```

---

## Self-modification

Knuckles is designed so that improving itself is not a special case. Point it
at its own repository:

```bash
slug knuckles.slug issue \
  --repo owner/knuckles \
  --issue 7
```

It will read the issue, explore the codebase, make changes, run tests, and open
a PR for review — the same process it uses for any other project. Prompt
improvements, manifest updates, new tool additions, and documentation changes
are all fair game. Code changes to the agent core require human review before
merge, which is the right level of caution for now.

---

## Acknowledgements

Knuckles is built on [Slug](https://sluglang.org) and draws inspiration from
minimal coding agents like Pi. The immutable session model, explicit tool
surface, and structured prompt architecture are designed to make agent behaviour
predictable, debuggable, and auditable.
