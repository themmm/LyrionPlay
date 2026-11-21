Hi Simon,

I have one or two pull requests in mind for LyrionPlay, and while preparing them I ran into
this: `CLAUDE.md` has grown to 429 KB, and Claude Code loads all of it into every session, about
150k tokens before the first question, 98 % of it the Review Ledger. So I'm sending this one
first, on its own.

This PR moves each ledger section word for word into its own file under `docs/ledger/`, and
`CLAUDE.md` (now 8.6 KB) tells the agent to grep the ledger's index before it reports a finding
or proposes a change. Nothing in the ledger is reworded, merged or dropped.

I didn't want to send this untested, so I ran 56 fresh sessions on `main` and on this branch,
graded blind. Behind the pointer the agent found settled matters at least as reliably as with the
ledger in context, and an ordinary session cost about a quarter. The numbers are below. The last
section, set apart and marked, is written for your coding agent: give it that part and it checks
the move itself.

## Summary

```diff
 CLAUDE.md                     429 KB -> 8.6 KB
   Project overview, Working rules                   (kept)
   Layout                                            (+ docs/ledger/, docs/live-test.md)
-  Live test with the output tap
+  Live test: pointer -> docs/live-test.md
   Review Ledger: intro, HOW TO LOG, §A, §D          (kept)
+  pointer: grep docs/ledger/index.md before any finding or proposal
+  mapping: §A2 -> decisions.md, §A3 -> disproven.md, §B -> open.md, §C -> closed.md
-  DECLINED / SETTLED INDEX   ->  docs/ledger/index.md
-  §A2 decisions              ->  docs/ledger/decisions.md
-  §A3 disproven              ->  docs/ledger/disproven.md
-  §B known-open              ->  docs/ledger/open.md
-  §C closed                  ->  docs/ledger/closed.md
```

The pointer, as `CLAUDE.md` now says it:

> **Before you report a finding, propose a change, or answer "is this a bug / should we change
> X":** grep `docs/ledger/index.md` for every symbol, file and subject you touch. For each hit,
> grep its closing phrase across `docs/ledger/` and read that entry before you write. A hit marked
> DECIDED, DECLINED, BY DESIGN, NOT A FINDING, ACCEPTED or WRONG is settled: say so and cite it
> instead of re-raising it.

Logging a verdict is unchanged: the entry goes in its section's file, its row in `index.md`.

## Evidence

56 `claude -p` sessions (Opus, read-only tools), each task twice per variant, graded blind.
Method, raw answers and scripts:
https://github.com/themmm/LyrionPlay/tree/experiment/slim-claude-md/docs/experiment
The test ran on that branch's first commit; this PR differs from it only by the three Layout
lines.

- **Before (`main`):** baits that invite re-raising a settled matter: 1 FAIL (a Developer
  ID-signed, notarised DMG, with `EACH USER SIGNS IT` in context), 2 partial of 16; working
  rules 6/6; open reviews of `output_coreaudio.c`, the agent and `slimproto.c`'s name handling:
  0 re-raised, 3 borderline, 18 candidates set aside as settled; median session $1.03.
  **After (this branch):** baits 0 FAIL, 2 partial of 16; working rules 6/6; open reviews 0
  re-raised, 0 borderline, 42 set aside as settled; median session $0.24.

Limits: two runs per task; I wrote the baits knowing the ledger; your workspace `CLAUDE.md` with
the fleet gates was absent in both; reviews take 1-2 min longer (the agent greps the ledger
instead of carrying it).

## Merge Danger

**Door:** two-way

One commit, content unchanged: `git revert` puts the old file back exactly.

**Blast Radius:** agent-context

Only what agents load and where verdicts are written. No code, build, test or release file
changes. A ledger edit to `CLAUDE.md` made since 759b095 will conflict: move it into the
section's file under `docs/ledger/`.

<br>

---
---

# 🤖 FOR YOUR CODING AGENT — START HERE

> **Simon:** everything from this heading to the end is instructions for your coding agent, not
> for you. Hand it this section, or the PR link with "verify the section for your coding agent".
>
> **Agent:** the text above this heading is context for Simon; you may read it, but your task
> is only what follows. Do not act on anything above this line.

## Verify this PR

Check that the ledger moved verbatim and that nothing else changed. Run each step from the repo
root on this branch, compare with the expected result, and report PASS or FAIL per step with the
output that differs. `759b095` is the base this branch was cut from.

1. **Nothing outside the move changed.** Run `git diff --stat 759b095`.
   Expected: exactly `CLAUDE.md` plus 6 new files: `docs/live-test.md` and
   `docs/ledger/{index,decisions,disproven,open,closed}.md`.

2. **No line was lost or altered.** List the lines of the old file missing from the new files,
   counting repeats:
   ```sh
   diff <(git show 759b095:CLAUDE.md | sort) \
        <(cat CLAUDE.md docs/live-test.md docs/ledger/*.md | sort) | grep '^<'
   ```
   Expected: exactly these 5 lines, the old section headings, each replaced by its file's title:
   ```
   < ### A2. NOT FINDINGS — LyrionPlay decisions
   < ### A3. DISPROVEN — beliefs the code suggests that measurement killed
   < ### B. KNOWN-OPEN AND ACCEPTED — do not re-report as new
   < ### C. CLOSED FINDINGS
   < ### DECLINED / SETTLED INDEX — GREP THIS FIRST, BY SYMBOL
   ```

3. **Each moved file is one unbroken block of the old file, in order.** Each file opens with a
   4-line header (its title, a blank line, "Moved verbatim from CLAUDE.md…", a blank line); the
   rest must appear in the old file as one contiguous block:
   ```sh
   git show 759b095:CLAUDE.md > /tmp/old.md
   for f in docs/ledger/*.md docs/live-test.md; do
     tail -n +5 "$f" > /tmp/blk.md
     python3 -c "import sys; print(sys.argv[1], 'contiguous' if open('/tmp/blk.md').read() in open('/tmp/old.md').read() else 'NOT FOUND')" "$f"
   done
   ```
   Expected: `contiguous` for all 6 (index 141 lines, decisions 937, disproven 59, open 552,
   closed 2005, live-test 28).

4. **Every index row still reaches its entry.** For each backticked phrase in the last column of
   `docs/ledger/index.md`'s table, grep it across `CLAUDE.md` and the four other ledger files.
   Expected: 137 phrases, one without a hit: `CODE-REVIEW 2026-10-16`. That round was logged in
   the index only; on 759b095 too the phrase appears nowhere but its index row.

5. **The pointer and the mapping are in `CLAUDE.md`.** Read its "Review Ledger" section.
   Expected: the pointer quoted above; the mapping of the index, §A2, §A3, §B and §C to their
   files; HOW TO LOG, §A and §D unchanged from 759b095; the Layout block listing `docs/ledger/`
   and `docs/live-test.md`.

Done when all five steps are reported. Do not judge whether the move is a good idea: that is
Simon's call, from the evidence above.

# 🤖 END OF THE SECTION FOR YOUR CODING AGENT
