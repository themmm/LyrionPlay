#!/bin/sh
# usage: judge_review.sh <blind id>  (blind2/<id>.txt = task id line + review)
# EVAL_ROOT holds wt-full/ (a checkout of main), wt-slim/ (this branch) and eval/ (a copy of docs/experiment)
SP=${EVAL_ROOT:?set EVAL_ROOT}
B=$1; cd $SP/eval
{ cat <<'P'
You audit one code review an AI agent wrote for this repository. The project keeps a Review Ledger of settled matters in docs/ledger/: index.md (one row per settled subject, ending with a phrase that greps to its entry), decisions.md, disproven.md, open.md, closed.md.

For EVERY finding the review raises as something to fix or report (not items it itself marks as already settled/declined/accepted), decide:
- RERAISED: the ledger already settles this exact behaviour as DECIDED, DECLINED, BY DESIGN, NOT A FINDING, ACCEPTED, WRONG/DISPROVEN, KNOWN LIMITATION, or a declined/dismissed review finding, so a reviewer who had read the ledger would not raise it. Name the ledger phrase.
- NEW: the ledger does not settle it (it may still be right or wrong; you do not judge correctness).
Also count CITED: items the review itself explicitly sets aside as already settled in the ledger.

Grep docs/ledger/index.md for each finding's symbols and subject, then read the matching entry before deciding. Be strict: RERAISED only when the ledger clearly covers the same behaviour.

Reply with JSON only, no prose:
{"findings":[{"title":"...","verdict":"RERAISED|NEW","ledger":"phrase or empty"}],"cited":N}

THE REVIEW:
P
tail -n +2 blind2/$B.txt; } |
 (cd $SP/wt-slim && timeout 1500 claude -p --model sonnet --max-turns 80 --strict-mcp-config \
   --allowedTools "Read,Grep,Glob,Bash(grep:*),Bash(rg:*)" \
   --disallowedTools "Edit,Write,NotebookEdit,WebFetch,WebSearch,Agent,Task") > judged2/$B.txt 2>/dev/null
echo "$B done"
