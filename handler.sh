#!/usr/bin/env bash

set -euo pipefail

MAX_SIGTERMS=5
SIGTERM_COUNT=0
CHILD_PIDS=()

########################################
# Child Process
########################################
child_process() {
    local CHILD_ID="$1"

    child_sigterm() {
        echo "[Child ${CHILD_ID} | PID ${BASHPID}] received SIGTERM"
    }

    trap child_sigterm SIGTERM

    echo "[Child ${CHILD_ID} | PID ${BASHPID}] alive"

    # Simulated workload
    while true; do
        sleep 2
    done
}

########################################
# Parent SIGTERM Handler
########################################
parent_sigterm() {
    SIGTERM_COUNT=$((SIGTERM_COUNT + 1))

    echo "[Parent $$] received SIGTERM (${SIGTERM_COUNT}/${MAX_SIGTERMS})"
    echo "[Parent $$] forwarding SIGTERM to children..."

    for pid in "${CHILD_PIDS[@]}"; do
        kill -TERM "$pid" 2>/dev/null || true
    done

    if [[ "$SIGTERM_COUNT" -ge "$MAX_SIGTERMS" ]]; then
        echo "[Parent $$] received ${MAX_SIGTERMS} SIGTERMs — shutting down"

        for pid in "${CHILD_PIDS[@]}"; do
            kill -TERM "$pid" 2>/dev/null || true
        done

        echo "[Parent $$] waiting for children to exit..."
        wait

        echo "[Parent $$] exiting"
        exit 0
    fi
}

trap parent_sigterm SIGTERM

########################################
# Spawn Random Children
########################################
NUM_CHILDREN=$(( RANDOM % 5 + 2 ))

echo "[Parent $$] spawning ${NUM_CHILDREN} children"

for i in $(seq 1 "$NUM_CHILDREN"); do
    child_process "$i" &
    pid=$!
    CHILD_PIDS+=("$pid")
done

echo "[Parent $$] children: ${CHILD_PIDS[*]}"

########################################
# Keep Parent Alive
########################################
while true; do
    sleep 1
done
