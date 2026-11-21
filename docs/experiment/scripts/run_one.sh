#!/bin/sh
# usage: run_one.sh <variant full|slim> <task id> <rep>
# EVAL_ROOT holds wt-full/ (a checkout of main), wt-slim/ (this branch) and eval/ (a copy of docs/experiment)
SP=${EVAL_ROOT:?set EVAL_ROOT}
V=$1; T=$2; R=$3
PROMPT=$(awk -F'\t' -v t="$T" '$1==t{print $3}' $SP/eval/tasks.tsv)
cd $SP/wt-$V || exit 1
printf '%s\n\nAnswer in this session. Read the repository as you need; do not modify any file.' "$PROMPT" |
  timeout 1800 claude -p --model opus --output-format json --max-turns 90 --strict-mcp-config \
    --allowedTools "Read,Grep,Glob,Bash(grep:*),Bash(rg:*),Bash(sed -n:*),Bash(git log:*),Bash(git show:*),Bash(ls:*),Bash(wc:*),Bash(head:*),Bash(cat:*)" \
    --disallowedTools "Edit,Write,NotebookEdit,WebFetch,WebSearch,Agent,Task" \
    > $SP/eval/out/$V-$T-$R.json 2> $SP/eval/out/$V-$T-$R.err
echo "$V $T $R exit=$?"
