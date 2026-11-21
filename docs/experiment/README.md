# Experiment: the Review Ledger behind a pointer instead of in CLAUDE.md

Run 2026-11-21 on LyrionPlay 0.4.14 (`main` at 759b095), Claude Code 2.1.316, model Opus for the
answers, Sonnet for the grading.

## The question

`CLAUDE.md` is 3,840 lines and 429 KB, about 98 % of it the Review Ledger, and Claude Code loads it
into every session. If the ledger moves to `docs/ledger/`, reached by a pointer in `CLAUDE.md`,
does an agent still find what is settled before it reports a finding or proposes a change?

## The two variants

- **full**: `main` as it is.
- **slim**: commit `1dca247` on this branch. Each ledger section moved **verbatim** to its own file
  (`docs/ledger/index.md`, `decisions.md` = §A2, `disproven.md` = §A3, `open.md` = §B,
  `closed.md` = §C; the live-test procedure to `docs/live-test.md`). `CLAUDE.md` keeps the overview,
  layout, working rules, the ledger's intro, HOW TO LOG, §A and §D, and a pointer telling the
  agent to grep `docs/ledger/index.md` for every symbol it touches before it reports or proposes
  anything (8.4 KB). Nothing was reworded. Every line of the old file is in exactly one place.

## Method

Each run is a fresh `claude -p` session in a checkout of one variant, so it loads that variant's
`CLAUDE.md` and nothing else of the project. Read-only tools only (Read, Grep, Glob, read-only
shell); no edits, no network, no MCP servers, no subagents. Every task ran twice per variant.

- **Round 1, 11 named tasks** (`tasks.tsv`, T* and C*):
  - 8 **baits**, each a question that invites re-raising one settled matter (model name, two LMS
    on one host, silence format, a stalled server, Developer ID, Follow's built-in fallback, the
    hog hiding the volume control, an offer lost in flight);
  - 3 **controls**, each needing a working rule that stays in `CLAUDE.md` (no `pkill`, ask for the
    device before a sound test, no Homebrew).
  - Graded **blind** by Sonnet against `rubric.tsv`: PASS, PARTIAL or FAIL.
- **Round 2, 3 open reviews** (R*): `output_coreaudio.c`; the agent and PlayerCore; the name
  handling in `slimproto.c`. No hint of what is settled.
  - Graded **blind** finding by finding (`scripts/judge_review.sh`): Sonnet greps the ledger for each
    finding and marks it RERAISED (the ledger settles it) or NEW. It also counts items the review
    itself set aside as settled.
  - Then checked by hand: every NEW finding grepped against the ledger.

Answers were anonymised before grading (`judged/round*/answers/`, keyed in `key.json`).

## Results

### Round 1: named tasks

| | full | slim |
|---|---|---|
| Baits, 16 runs | 13 PASS, 2 PARTIAL, **1 FAIL** | 14 PASS, 2 PARTIAL, **0 FAIL** |
| Controls, 6 runs | 6/6 PASS | 6/6 PASS |
| Bait answers that cite the ledger | 13/16 | 16/16 |
| Cost, 22 runs | $21.68 (median $1.03) | $6.69 (median $0.24) |
| Median duration / turns | 24 s / 4 | 21 s / 6 |

- The FAIL (full, T5): its headline recommendation was a Developer ID-signed, notarised DMG,
  although `EACH USER SIGNS IT` was in context; the other full T5 run was PARTIAL for the same.
- Slim's PARTIALs (T2, T4) cited the settled entry correctly but also listed side observations
  close to it.

### Round 2: open reviews

| | full | slim |
|---|---|---|
| Findings reported, 6 runs | 24 | 16 |
| RERAISED (blind judge) | 0 | 0 |
| Borderline on the hand check | 3 | 0 |
| Items the review set aside as settled | 18 | 42 |
| Cost, 6 runs | $12.54 | $10.93 |
| Turns per run / duration | 9-18 / 3-5 min | 18-40 / 4-7 min |

Full's three borderline findings: DoP cut short without Exclusive mode (close to `DOP WORKS
WITHOUT EXCLUSIVE MODE`), `ask_server_uuid` having no overall limit (close to `UUID ASK
RESIDUALS`), and a lost UUID reply judged by address (the residual §A2 states under `One LMS at two
addresses`). In R2 the full variant set aside nothing as settled; slim grepped the ledger for each
candidate.

Per-run numbers: `results.csv`.

## What this does not show

- Two runs per task: a sample, not a proof.
- The baits were written knowing the ledger, and each names its subject.
- Only the verbatim move is tested. ADRs, de-duplicating the version history against
  `CHANGELOG.md`, or thinning §C are not.
- The workspace `CLAUDE.md` one level up (the fleet gates) was absent in both variants: this
  machine has none.
- Whether the NEW findings are real bugs was not checked.

## Re-running

The scripts read `EVAL_ROOT`, a directory holding `wt-full/` (a checkout of `main`), `wt-slim/` and
`eval/` (a copy of this folder with an `out/` directory). **Check out `wt-slim` at `1dca247`, not
at this branch's tip:** this folder holds the rubric, which an agent in the slim checkout could
grep.

```sh
cd "$EVAL_ROOT/eval"
for r in 1 2; do for v in full slim; do cut -f1 tasks.tsv | while read t; do echo "$v $t $r"; done; done; done |
  xargs -P 6 -n 3 ./scripts/run_one.sh
```

Graders: `scripts/judge_one.sh` (round 1, on `blind/<id>.txt`), `scripts/judge_review.sh` (round
2, on `blind2/<id>.txt`); each file is the task id on the first line, then the answer.
