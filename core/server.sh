#!/usr/bin/env bash

set -euo pipefail

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$BASE/config/ezra.conf"
PID_FILE="$BASE/runtime/server.pid"
LOG_FILE="$BASE/logs/server.log"

source "$CONFIG"

server_running() {
    [ -f "$PID_FILE" ] || return 1

    local pid
    pid="$(cat "$PID_FILE" 2>/dev/null)"

    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

server_healthy() {
    curl -fsS \
        --max-time 2 \
        "http://${HOST}:${PORT}/health" \
        >/dev/null 2>&1
}

clean_stale_server() {
    if [ -f "$PID_FILE" ] && ! server_running; then
        rm -f "$PID_FILE"
    fi
}

start_server() {
    clean_stale_server

    if server_healthy; then
        return 0
    fi

    if server_running; then
        kill "$(cat "$PID_FILE")" 2>/dev/null || true
        sleep 1
    fi

    rm -f "$PID_FILE"
    : > "$LOG_FILE"

    if ! command -v llama-server >/dev/null 2>&1; then
        echo
        echo "llama-server was not found."
        echo "Run the EzraOS installer first:"
        echo
        echo "    bash install.sh"
        echo
        return 1
    fi

    nohup llama-server \
        -hf "$MODEL" \
        -c "$CONTEXT" \
        -np 1 \
        -t "$THREADS" \
        -b "$BATCH" \
        -ub "$UBATCH" \
        --host "$HOST" \
        --port "$PORT" \
        > "$LOG_FILE" 2>&1 &

    echo $! > "$PID_FILE"

    local attempts=0

    while [ "$attempts" -lt 120 ]; do

        if server_healthy; then
            return 0
        fi

        if ! server_running; then
            echo
            echo "The AI server stopped unexpectedly."
            echo
            echo "Recent server log:"
            echo
            tail -n 25 "$LOG_FILE"
            return 1
        fi

        attempts=$((attempts + 1))
        sleep 1

    done

    echo
    echo "The AI server took too long to start."
    echo "Log file: $LOG_FILE"
    return 1
}

stop_server() {
    clean_stale_server

    if server_running; then

        kill "$(cat "$PID_FILE")" 2>/dev/null || true

        local attempts=0

        while server_running && [ "$attempts" -lt 10 ]; do
            attempts=$((attempts + 1))
            sleep 1
        done

    fi

    rm -f "$PID_FILE"
}

status_server() {
    clean_stale_server

    if server_healthy; then
        echo "Running"
    else
        echo "Stopped"
    fi
}

case "${1:-start}" in

    start)
        start_server
        ;;

    stop)
        stop_server
        ;;

    restart)
        stop_server
        start_server
        ;;

    status)
        status_server
        ;;

    *)
        echo "Usage: server.sh {start|stop|restart|status}"
        exit 1
        ;;

esac
