# Linux Practice

Notes and small bash scripts from learning Linux on Ubuntu (WSL2),
with a focus on log analysis and IT automation.

## Contents

| File | Description |
|---|---|
| `linux-notes.md` | Commands and concepts I have learned, with short explanations |
| `count-errors.sh` | Counts the `ERROR` lines in a log file passed as an argument |
| `log-summary.sh` | Prints the number of `ERROR` lines for each `.log` file in a folder |
| `server.log` | Sample log file to try the scripts |

## Usage

```bash
chmod +x count-errors.sh log-summary.sh
./count-errors.sh server.log
./log-summary.sh .
```

## Status

Work in progress. New topics are added as I learn them.
