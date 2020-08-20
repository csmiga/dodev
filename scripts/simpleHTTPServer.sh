#!/usr/bin/env bash

# Enable debug mode (-x). Disable debug mode (+x)
set +x

: <<'END'
Author:      Christopher Smiga
Address:     5030 Sugarloaf Parkway
Address:     Lawrenceville, GA. 30044
e-Mail:      chsmiga@cisco.com

Team:        Peloton
Team eMail:  peloton@cisco.com

File:        simpleHTTPServer.sh
END

PORT=8080

case "$1" in
    start)
        cd ${HOME}/tsung_log
        trap '' HUP
        python -m SimpleHTTPServer ${PORT} &>/dev/null &
        ;;
    stop)
        kill $(ps -ef | grep SimpleHTTPServer | awk '{print $2}') &>/dev/null
        ;;
    status)
        PID=$(ps -ef | grep SimpleHTTPServer | grep ${PORT} | awk '{print $2}')
        if [ -z ${PID} ]
        then
            echo 'STATUS: SimpleHTTPServer (stopped)'
        else
            echo 'STATUS: SimpleHTTPServer (running)'
        fi
        ;;
    help)
        echo ''
        echo 'HELP:'
        echo 'status - Check running state of web server'
        echo 'start - Start Web Server'
        echo 'stop - Stop Server'
        echo ''
        ;;
    *)
        echo ''
        echo 'Usage:' $0 '{help|status|start|stop}'
        echo ''
        echo 'Syntax:  ./simpleHTTPServer.sh start'
        echo ''
        exit 1
esac

exit 0

