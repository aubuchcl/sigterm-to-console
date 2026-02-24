#!/usr/bin/env bash

set -euo pipefail

COUNT=0
MAX=5

handle_sigterm() {
    COUNT=$((COUNT + 1))
    echo "Received SIGTERM (${COUNT}/${MAX})"

    if [[ "$COUNT" -ge "$MAX" ]]; then
        echo "Received SIGTERM ${MAX} times. Exiting..."
        exit 0
    fi
}

trap handle_sigterm SIGTERM

echo "Container started. PID=$$"
echo "Waiting for SIGTERM signals..."

# Keep process alive
while true; do
    sleep 1
done
