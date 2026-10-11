# Long runs

Claude Code runs on the GPU server over SSH. A dropped connection ends the
session and every child process.

## Start

Start every training, evaluation, or data job detached in `tmux`, with its output
saved to a log:

    mkdir -p runs
    tmux new-session -d -s <entry-id> bash -c \
      '<command> 2>&1 | tee runs/<entry-id>.log; echo "EXIT ${PIPESTATUS[0]}" >> runs/<entry-id>.log'

Reason: `PIPESTATUS` exists only in bash, and the server's default shell may differ.

Never run a job in the foreground. Never use the Bash tool's background mode for
a job.
Reason: both are children of the session, so a dropped SSH link kills the job.

Before the start, check free GPU memory with `nvidia-smi`. Name the GPUs with
`CUDA_VISIBLE_DEVICES`.

Write the tmux session name and the log path in the Run line of the log entry.
See `~/.claude/research/guides/experiment-log.md`.

## Watch

Watch the log file, not the process. Use the Monitor tool with a filter that
matches progress, the end, and every failure:

    tail -n 0 -F runs/<entry-id>.log | grep -E --line-buffered "EXIT |Traceback|Error|OOM|Killed|nan|<progress pattern>"

A monitor stops after 30 minutes. Re-arm it until the `EXIT` line appears.
On `EXIT`, send a push notification with the exit code and the last metric.

Silence is not success. If the log stops growing, check `tmux ls` and
`nvidia-smi` before you report.

## Stop

Never kill a tmux session you did not start. Ask before stopping one you did.
