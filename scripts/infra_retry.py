#!/usr/bin/env python3
import datetime
import subprocess
import time
import sys
import os
from pathlib import Path

# Configuration
# ==============================================================================
COMMAND_TO_RUN = ["terraform", "apply", "--auto-approve"]

# Resolves to: .../terraform/kls-infra-02 relative to this script location
# Path(__file__).resolve() = /path/to/scripts/retry.py
# .parent = /path/to/scripts
# .parent.parent = /path/to
# / "terraform" / "kls-infra-02"
SCRIPT_DIR = Path(__file__).resolve().parent
WORKING_DIR = SCRIPT_DIR.parent / "terraform" / "kls-infra-02"

START_HOUR = 1
END_HOUR = 4
RETRY_INTERVAL_SECONDS = 300  # 5 minutes
LOG_FILE = SCRIPT_DIR / "infra_retry.log"
# ==============================================================================

def log(message):
    """Logs to stdout and appends to the log file."""
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted_message = f"[{timestamp}] {message}"
    print(formatted_message)
    
    try:
        with open(LOG_FILE, "a") as f:
            f.write(formatted_message + "\n")
    except Exception as e:
        print(f"[WARN] Could not write to log file: {e}")

def is_within_window():
    now = datetime.datetime.now()
    if START_HOUR < END_HOUR:
        return START_HOUR <= now.hour < END_HOUR
    else:
        # Handles spanning midnight (e.g., 23 to 02)
        return now.hour >= START_HOUR or now.hour < END_HOUR

def run_command_streaming():
    """Runs the command and streams output to log in real-time."""
    log(f"Attempting to run: {' '.join(COMMAND_TO_RUN)}")
    log(f"Working Directory: {WORKING_DIR}")

    if not WORKING_DIR.exists():
        log(f"ERROR: Working directory does not exist: {WORKING_DIR}")
        return False

    try:
        # Popen allows us to read output while the process is running
        process = subprocess.Popen(
            COMMAND_TO_RUN,
            cwd=WORKING_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, # Merge stderr into stdout
            text=True,
            bufsize=1 # Line buffered
        )

        # Iterate over stdout line by line
        for line in process.stdout:
            # strip() removes trailing newlines so we don't get double spacing
            log(f"[CMD] {line.strip()}")

        process.wait()

        if process.returncode == 0:
            log("Command executed successfully.")
            return True
        else:
            log(f"Command failed with exit code {process.returncode}.")
            return False

    except FileNotFoundError:
        log(f"Command not found: {COMMAND_TO_RUN[0]}")
        return False
    except Exception as e:
        log(f"An unexpected error occurred: {e}")
        return False

def main():
    log("Starting infra_retry script.")

    # Initial check
    if not is_within_window():
        log(f"Current time is outside window ({START_HOUR}:00 - {END_HOUR}:00). Exiting.")
        sys.exit(0)

    # Loop while in window
    while is_within_window():
        success = run_command_streaming()
        
        if success:
            log("Task completed successfully. Exiting.")
            sys.exit(0)
        else:
            log(f"Task failed. Retrying in {RETRY_INTERVAL_SECONDS} seconds...")
            
            # Smart sleep: check window before sleeping full duration? 
            # (Optional, but simple sleep is usually fine)
            time.sleep(RETRY_INTERVAL_SECONDS)

            # Re-check window immediately after waking up
            if not is_within_window():
                log("Time window expired while waiting. Exiting.")
                sys.exit(1)

    log("Time window expired. Task did not complete successfully.")
    sys.exit(1)

if __name__ == "__main__":
    main()