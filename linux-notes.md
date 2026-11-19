# Linux Notes

Personal notes from learning Linux on Ubuntu (WSL2) for IT and infrastructure work.
Each section lists commands I have actually used, with a short explanation.

> Status: work in progress. Last updated: 19 Nov 2026 (added loops and log summary).

## Contents

1. [Setup: Ubuntu on WSL2](#1-setup-ubuntu-on-wsl2)
2. [Navigation](#2-navigation)
3. [Files and folders](#3-files-and-folders)
4. [Reading and writing text](#4-reading-and-writing-text)
5. [Permissions](#5-permissions)
6. [Installing software with apt](#6-installing-software-with-apt)
7. [First bash script](#7-first-bash-script)
8. [Loops with for](#8-loops-with-for)
9. [Keyboard shortcuts](#9-keyboard-shortcuts)
10. [Lessons learned](#10-lessons-learned)

---

## 1. Setup: Ubuntu on WSL2

WSL2 runs Ubuntu inside Windows, without a separate virtual machine.

| Command / action | What it does |
|---|---|
| `wsl --install` | Installs WSL and Ubuntu (run PowerShell as administrator, then reboot) |
| `wsl --version` | Checks the installed WSL version (PowerShell) |
| `wsl` | Opens Ubuntu from PowerShell |
| Start menu → *Ubuntu* | Opens Ubuntu directly in the Linux home folder |

Notes:

- `/mnt/c/` is the Windows `C:` drive as seen from Linux. Do not work in `/mnt/c/Windows/...`: those are Windows system files.
- If Ubuntu is started from PowerShell, it opens in the current Windows folder. Use `cd ~` to go to the Linux home folder.
- When typing a password in the terminal, no characters are shown. This is normal.

## 2. Navigation

| Command | What it does |
|---|---|
| `pwd` | Shows the current directory |
| `cd ~` | Goes to the home directory (`/home/<user>`) |
| `cd ..` | Goes up one directory |
| `cd <folder>` | Enters a folder |
| `ls` | Lists files |
| `ls -l` | Lists files with details (permissions, owner, size, date) |
| `ls -la` | Same, including hidden files (names starting with `.`) |
| `tree` | Shows folders as a tree (install with `sudo apt install tree`) |

Reading the prompt `anna@DESKTOP-NAME:~/linux-lab$`:

- `anna` is the user, `DESKTOP-NAME` is the machine.
- `~/linux-lab` is the current folder (`~` means the home directory).
- `$` means a normal user; `#` would mean root.

In `ls -la`, `.` is the current folder and `..` is the parent folder.

## 3. Files and folders

| Command | What it does |
|---|---|
| `mkdir <name>` | Creates a folder |
| `touch <file>` | Creates an empty file |
| `cp <source> <destination>` | Copies a file (the original stays) |
| `mv <old> <new>` | Renames or moves a file or folder (the original is no longer there) |
| `nano <file>` | Opens a simple text editor |

In `nano`: `Ctrl+O` then `Enter` saves, `Ctrl+X` exits.

Careful: `rm` deletes without a recycle bin. Not used yet; to be covered with care.

## 4. Reading and writing text

| Command | What it does |
|---|---|
| `echo "text" > file` | Writes text to a file and **overwrites** it |
| `echo "text" >> file` | **Appends** text to the end of a file |
| `cat <file>` | Prints the whole file |
| `tail -n 2 <file>` | Prints the last 2 lines |
| `grep <word> <file>` | Prints the lines containing the word |
| `grep -c <word> <file>` | Counts the matching lines |
| `<command1> \| <command2>` | Pipe: sends the output of the first command to the second |
| `wc -l` | Counts the lines it receives |

Examples:

```bash
grep ERROR server.log              # show error lines
grep -c ERROR server.log           # count error lines
grep ERROR server.log | wc -l      # same result, using a pipe
```

Options go **before** the file name (`grep -c ERROR file`). The other order works on Ubuntu but not on every system.

## 5. Permissions

`ls -l` shows ten characters at the start of each line, for example `-rw-r--r--`:

| Position | Meaning |
|---|---|
| 1st character | Type: `-` file, `d` directory |
| Next 3 | Permissions of the **owner** |
| Next 3 | Permissions of the **group** |
| Last 3 | Permissions of **others** |

Each group uses `r` (read), `w` (write), `x` (execute; for folders: enter). A `-` means "not allowed".

| Command | What it does |
|---|---|
| `chmod +x <file>` | Makes a file executable |
| `chmod g-r <file>` | Removes read permission from the group |
| `chmod g-r,o-r <file>` | Removes read permission from group and others |

Letters: `u` = owner (user), `g` = group, `o` = others. `+` adds, `-` removes.

Numeric form: `600` = `-rw-------` (read and write for the owner only). Typical for private files such as SSH keys.

## 6. Installing software with apt

| Command | What it does |
|---|---|
| `sudo <command>` | Runs a command as administrator (asks for the password) |
| `sudo apt update` | Refreshes the list of available packages (installs nothing) |
| `sudo apt upgrade` | Installs the available updates |
| `sudo apt install <name>` | Installs a program |

Use `sudo` only for commands I understand and that come from a reliable source. After an upgrade, the prompt coming back means the command has finished, even if the last line looks like a log message.

## 7. First bash script

`count-errors.sh`: counts the lines containing `ERROR` in a log file passed as an argument.

```bash
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ./count-errors.sh <file>"
    exit 1
fi
echo "Errors found:"
grep -c ERROR "$1"
```

How to run it:

```bash
chmod +x count-errors.sh
./count-errors.sh server.log
```

| Element | Meaning |
|---|---|
| `#!/bin/bash` | First line: tells the system to run the file with bash |
| `./script.sh` | Runs a script in the current folder (needs the `x` permission) |
| `$1` | First argument passed to the script |
| `[ -z "$1" ]` | True when `$1` is empty |
| `exit 1` | Stops the script and reports an error |

Notes:

- Bash runs lines from top to bottom, so the argument check must come **before** the command that uses the argument.
- Without a check, `grep` with no file waits for keyboard input and the script seems to hang.
- Quote variables (`"$1"`) so that file names with spaces do not break the script.

## 8. Loops with for

A `for` loop repeats commands once for each item in a list. Useful to run the same check on many log files.

```bash
for f in *.log; do echo "$f"; done
```

Run my script on every `.log` file in the current folder:

```bash
for f in *.log; do echo "$f"; ./count-errors.sh "$f"; done
```

| Element | Meaning |
|---|---|
| `for f in *.log` | For each file ending in `.log`, call it `f` |
| `*` | Wildcard: matches any text |
| `do ... done` | Wraps the commands to repeat (`do` is written only once) |
| `;` | Separates commands inside the loop |
| `"$f"` | The current item; changes at every iteration |

Notes:

- `*.log` only matches files in the **current folder**, not in subfolders.
- `$f` is the variable of the loop; `$1` is the variable of the script. In the loop, `"$f"` is passed to the script and becomes `$1` there.
- The script handles one file per run. The loop starts it once per file.
- Forgetting the argument (`./count-errors.sh` without `"$f"`) triggers the usage message of the script.

### Script: `log-summary.sh`

Prints one line per log file in a folder: the file name and the number of `ERROR` lines.

```bash
#!/bin/bash

if [ -z "$1" ]; then echo "Usage: ./log-summary.sh <folder>"; exit 1; fi

for f in "$1"/*.log; do echo "$f: $(grep -c ERROR "$f")"; done
```

```bash
./log-summary.sh .         # current folder
./log-summary.sh archive   # a subfolder
```

Example output:

```
./backup-server.log: 2
./server.log: 2
```

| Element | Meaning |
|---|---|
| `"$1"/*.log` | All `.log` files in the folder passed as the first argument |
| `$(command)` | Runs the command and inserts its output into the text |
| `;` | Needed between `echo "..."` and `exit 1`, otherwise `exit 1` becomes text |

Notes:

- `$(...)` runs a command inside a string; `$2` is only the second argument, not a command.
- Quotes inside `$( )` are independent from the outer quotes.
- Without the `exit 1` check, an empty `$1` turns the path into `/*.log` (the system root).

## 9. Keyboard shortcuts

| Shortcut | What it does |
|---|---|
| `Ctrl+C` | Interrupts a running command |
| `Ctrl+D` | Ends keyboard input (end of input) |

## 10. Lessons learned

- `>` overwrites a file, `>>` appends to it.
- `cp` keeps the original, `mv` does not.
- Options before file names.
- Check the arguments at the start of a script and print a clear message.
- Use `$(command)` to put a command result inside a text.
- In a loop, pass the loop variable (`"$f"`) to the script as an argument.
- Practice in a throwaway folder (`linux-lab`) before touching anything important.

## Next topics

- Git inside WSL, to version these scripts
- Docker on Ubuntu
