# Proposal: move the Review Ledger out of CLAUDE.md (step 1: a verbatim move, tested)

## The problem

`CLAUDE.md` is 3,840 lines and 429 KB. The Review Ledger is 421 KB of that (98 %); the overview,
layout, working rules and live-test procedure are about 7 KB. Claude Code loads the whole file
into every session, about 150k tokens before the first question, whether the session is a review
or a one-line fix. The ledger grows with every round, so the cost does too.

## The proposal

Move each ledger section, **word for word**, into its own file, and point at them from
`CLAUDE.md`:

| Now | Moves to |
|---|---|
| DECLINED / SETTLED INDEX | `docs/ledger/index.md` |
| §A2 NOT FINDINGS — LyrionPlay decisions | `docs/ledger/decisions.md` |
| §A3 DISPROVEN | `docs/ledger/disproven.md` |
| §B KNOWN-OPEN AND ACCEPTED | `docs/ledger/open.md` |
| §C CLOSED FINDINGS | `docs/ledger/closed.md` |
| Live test with the output tap | `docs/live-test.md` |

`CLAUDE.md` keeps the overview, layout, working rules, the ledger's intro, HOW TO LOG, §A and §D,
the old-name -> file mapping (so every "§A2", "§C" reference stays valid), and this pointer:

> **Before you report a finding, propose a change, or answer "is this a bug / should we change
> X":** grep `docs/ledger/index.md` for every symbol, file and subject you touch. For each hit,
> grep its closing phrase across `docs/ledger/` and read that entry before you write. A hit marked
> DECIDED, DECLINED, BY DESIGN, NOT A FINDING, ACCEPTED or WRONG is settled: say so and cite it
> instead of re-raising it.

`CLAUDE.md` goes from 429 KB to 8.4 KB. No entry is reworded, merged or dropped; every line of
the old file is in exactly one new place. Logging a verdict works as now: the entry goes in its
section's file, its row in `index.md`.

## The evidence

I tested this before proposing it: fresh `claude -p` sessions (Opus, read-only tools) on `main`
and on the slim layout, the same tasks twice each, graded blind. Method, raw answers, verdicts and
scripts are in `docs/experiment/` on the branch.

**Named questions that invite re-raising a settled matter** (model name, two LMS on one host,
silence format, a stalled server, Developer ID, Follow's built-in fallback, the hog hiding the
volume control, an offer lost in flight), plus three working-rule controls:

| | `main` | slim |
|---|---|---|
| Settled matter re-raised (16 runs) | **1 FAIL**, 2 partial | **0 FAIL**, 2 partial |
| Working rules kept (6 runs) | 6/6 | 6/6 |
| Answers citing the ledger | 13/16 | 16/16 |
| Median cost per session | $1.03 | $0.24 |

The one FAIL was on `main`: it recommended a Developer ID-signed, notarised DMG with `EACH USER
SIGNS IT` in its context.

**Open reviews** (`output_coreaudio.c`; the agent and PlayerCore; the name handling in
`slimproto.c`), every finding checked against the ledger:

| | `main` | slim |
|---|---|---|
| Findings re-raising a settled matter | 0, plus 3 borderline | 0 |
| Candidates set aside as settled | 18 | 42 |
| Cost / duration per review | similar | similar, 1-2 min longer |

With the ledger always in context, the review rarely checked it: in one task it set nothing aside.
Behind the pointer, the agent grepped the index for each candidate.

## Limits

- Two runs per task: a sample.
- I wrote the baits knowing the ledger.
- Your workspace `CLAUDE.md` with the fleet gates was not present in either variant.
- Reviews take more steps: the agent reads the ledger instead of carrying it.
- Only the verbatim move is tested.

## Not part of this step

Each needs its own decision and would be a later step:

- §A2's decisions as ADRs;
- the version history in §A2 de-duplicated against `CHANGELOG.md`;
- §C archived.

## Undoing it

One commit, reverted with `git revert`. The content is unchanged, so nothing is lost either way.
