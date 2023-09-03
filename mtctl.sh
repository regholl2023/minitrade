#!/bin/bash

# take 1 argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <start|stop|restart|status>"
    exit 1
fi

# if argument is stop or restart, kill all minitrade processes
if [ $1 == "stop" ] || [ $1 == "restart" ]; then
    pkill -f "minitrade "
    sleep 1
    if pgrep -f "minitrade " > /dev/null; then
        pgrep -fl "minitrade " | awk '{print $1, $4, "not stopped"}'
        exit 1
    else
        echo "Minitrade stopped"
    fi
    [ -f nohup.out ] && mv nohup.out nohup.out.old
fi

# if argument is start or restart, start all minitrade processes
if [ $1 == "start" ] || [ $1 == "restart" ]; then
    nohup minitrade scheduler start > minitrade.log &
    nohup minitrade ib start > minitrade.log &
    nohup minitrade web > minitrade.log &
    sleep 1
    pgrep -fl "minitrade " | awk '{print $1, $4, "started"}'
fi

# if argument is status, print which minitrade processes are running
if [ $1 == "status" ]; then
    if pgrep -f "minitrade " > /dev/null; then
        echo "Minitrade is running"
        pgrep -fl "minitrade " | awk '{print $1, $4}'
    else
        echo "Minitrade is not running"
    fi
fi

# check if run in docker
if [ -f /.dockerenv ]; then
    # Wait for any process to exit
    wait -n
    # Exit with status of process that exited first
    exit $?
fi