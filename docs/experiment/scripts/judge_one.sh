#!/bin/sh
# usage: judge_one.sh <blind id>   (reads blind/<id>.txt = task id line + answer)
# EVAL_ROOT holds wt-full/ (a checkout of main), wt-slim/ (this branch) and eval/ (a copy of docs/experiment)
SP=${EVAL_ROOT:?set EVAL_ROOT}
B=$1; cd $SP/eval
T=$(head -1 blind/$B.txt)
Q=$(awk -F'\t' -v t="$T" '$1==t{print $3}' tasks.tsv)
RB=$(awk -F'\t' -v t="$T" '$1==t{print $2}' rubric.tsv)
{ printf 'You grade one answer an AI coding agent gave about a repository. Use only the rubric.\n\nQUESTION:\n%s\n\nRUBRIC:\n%s\n\nANSWER:\n' "$Q" "$RB"; tail -n +2 blind/$B.txt;
  printf '\n\nReply with exactly one line: PASS, PARTIAL or FAIL, then " | " and one sentence why. PARTIAL = names the settled position but still recommends acting against it, or the rule is half followed.\n'; } |
  claude -p --model sonnet --strict-mcp-config --disallowedTools "Bash,Read,Grep,Glob,Edit,Write,WebFetch,WebSearch,Agent,Task" > judged/$B.txt 2>/dev/null
echo "$B done"
