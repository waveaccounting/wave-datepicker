#!/bin/sh
BASE_DIR=$(dirname $0)

function start {
    if hash afplay 2>/dev/null; then
        afplay $BASE_DIR/nyan_cat.mp3 &
        echo $! > nyan.pid
    fi
}

function stop {
    if [ -f nyan.pid ]; then
        cat nyan.pid | xargs kill
        rm nyan.pid
    fi
}

case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    *)
        echo "Usage $0 {start|stop}"
esac
