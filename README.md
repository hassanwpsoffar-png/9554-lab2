# Antivirus and Restore System

## 1. Project Overview

This project uses Bash scripts to monitor a directory, detect malicious files, and move them to a quarantine directory.

### Folder Structure

```text
antivirus-project/
├── antivirusd.sh
├── restore.sh
├── Makefile
├── README.md
```

- `antivirusd.sh`: Detects and quarantines malicious files.
- `restore.sh`: Allows users to restore or permanently delete quarantined files.
- `Makefile`: Creates the quarantine directory and runs the scripts.
- `README.md`: Explains the project.

The snapshot files `directory-info.last` and `directory-info.new` are created when the antivirus script runs.

## 2. Prerequisites and Installation

The project requires Ubuntu and Bash, Make, grep, and standard Linux commands.

Install the required packages using:

```bash
sudo apt update
sudo apt install bash make grep coreutils
```

## 3. Running the Scripts

### Run the Antivirus

1. Open the terminal in the project directory.
2. Make the scripts executable:

```bash
chmod +x antivirusd.sh restore.sh
```

3. Start the antivirus:

```bash
make antivirusd
```

The script scans immediately, then checks for directory changes every five seconds. It moves files matching either detection rule to quarantine.

Press `Ctrl + C` to stop it.

### Run the Restore Tool

First, stop the antivirus. Then run:

```bash
make restore
```

Choose a file by number, then select one of these options:

1. Restore the file to the monitored directory.
2. Permanently delete the file.
3. Leave the file unchanged and return to the list.

Enter `0` to exit.

## 4. Flagged Extensions and Keywords

The required lists are defined inside the `scan_dir()` function in `antivirusd.sh`.

- **Flagged extensions:** `.exe`, `.bat`, `.vbs`, `.scr`, `.ps1`. These are checked in the `case` statement.
- **Flagged keywords:** `virus`, `trojan`, `malware`, `worm`, `ransomware`. These are checked by the `grep -Eiq` command.

The keyword check is case-insensitive. A file is considered malicious if it matches either rule.
## Whitelist

The whitelist is stored in `whitelist.txt` and saves the SHA-256 hashes of files marked as safe.

When the user selects option 1 in `restore.sh`, the file's hash is added to the whitelist before the file is restored.

During each scan, `antivirusd.sh` calculates the hash of each regular file and checks whether it exists in the whitelist. If the hash matches, the file is skipped and is not quarantined.

The whitelist persists between runs, so restored files remain recognized as safe after the antivirus is restarted. If a file's contents change, its hash changes and it will be scanned normally.
