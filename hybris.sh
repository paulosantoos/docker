#!/bin/bash
# Deskription: Script to start, stop and check status of hybris
# Date: 10/01/2017
# Author: Helisandro Krepel
# Maintainer: Paulo Henrique dos Santos
### BEGIN INIT INFO
# Provides:          hybris
# Required-Start:    $all
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Script to start, stop and check status of hybris
# Description:       Script to start, stop and check status of hybris
### END INIT INFO


###################### CONSTANTS #######################
HYBRIS_USER="hybris"
HYBRIS_DIR="/app/hybris/hybris"
HYBRIS_BIN_DIR="$HYBRIS_DIR/bin/platform"
HYBRIS_PID="$HYBRIS_BIN_DIR/tomcat/bin/hybrisPlatform.pid"
########################################################

######################K# METHODS #######################
do_start(){
    current_user=`/usr/bin/whoami`
    if [ "$current_user" = "$HYBRIS_USER" ]; then
        cd "$HYBRIS_BIN_DIR"; ./hybrisserver.sh start
    else
        /sbin/runuser -l  "$HYBRIS_USER" -c "cd $HYBRIS_BIN_DIR; ./hybrisserver.sh start"
    fi;
}

do_stop(){
    current_user=`/usr/bin/whoami`
    if [ "$current_user" = "$HYBRIS_USER" ]; then
        cd "$HYBRIS_BIN_DIR"; ./hybrisserver.sh stop
    else
        /sbin/runuser -l  "$HYBRIS_USER" -c "cd $HYBRIS_BIN_DIR; ./hybrisserver.sh stop"
    fi;
}

do_ant_clean(){
    echo "Running ant clean..."
    current_user=`/usr/bin/whoami`
    if [ "$current_user" = "$HYBRIS_USER" ]; then
        cd "$HYBRIS_BIN_DIR"; . ./setantenv.sh; ant clean
    else
        /sbin/runuser -l  "$HYBRIS_USER" -c "cd $HYBRIS_BIN_DIR; . ./setantenv.sh; ant clean"
    fi;
}

do_ant_all(){
    echo "Running ant all..."
    current_user=`/usr/bin/whoami`
    if [ "$current_user" = "$HYBRIS_USER" ]; then
        cd "$HYBRIS_BIN_DIR"; . ./setantenv.sh; ant all
    else
        /sbin/runuser -l  "$HYBRIS_USER" -c "cd $HYBRIS_BIN_DIR; . ./setantenv.sh; ant all"
    fi;
}

do_ant_clean_all(){
    echo "Running ant clean all..."
    current_user=`/usr/bin/whoami`
    if [ "$current_user" = "$HYBRIS_USER" ]; then
        cd "$HYBRIS_BIN_DIR"; . ./setantenv.sh; ant clean all
    else
        /sbin/runuser -l  "$HYBRIS_USER" -c "cd $HYBRIS_BIN_DIR; . ./setantenv.sh; ant clean all"
    fi;
}

do_ant_customize_clean_all(){
    echo "Running ant clean all..."
    current_user=`/usr/bin/whoami`
    if [ "$current_user" = "$HYBRIS_USER" ]; then
        cd "$HYBRIS_BIN_DIR"; . ./setantenv.sh; ant customize clean all
    else
        /sbin/runuser -l  "$HYBRIS_USER" -c "cd $HYBRIS_BIN_DIR; . ./setantenv.sh; ant customize clean all"
    fi;
}

do_status(){
    if [ ! -f "$HYBRIS_PID" ]; then
        echo "Hybris is not running"
    else
        pid=`cat "$HYBRIS_PID"`
        is_running=`/bin/ps aux | grep "$pid" | grep -v "grep"`
        if [ "$is_running" != "" ]; then
            echo "Hybris is running (pid: $pid)"
        else
            echo "Hybris is not running"
        fi;
    fi;
}
########################################################

######################### MAIN ########################
case "$1" in
    start)
        do_start
    ;;
    stop)
        do_stop
    ;;
    restart)
        do_stop
        sleep 15
        do_start
    ;;
    ant_clean|clean)
        do_ant_clean
    ;;
    ant_all|all)
        do_ant_all
    ;;
    ant_clean_all|clean_all)
        do_ant_clean_all
    ;;
    ant_customize_clean_all|customize_clean_all)
        do_ant_customize_clean_all
    ;;
    status)
	    do_status
	;;
    *)
        echo "Usage: $SCRIPTNAME {start|stop|status|restart|clean(ant_clean)|ant_all(all)|clean_all(ant_clean_all)|customize_clean_all(ant_customize_clean_all)}" >&2
        exit 3
    ;;
esac

exit 0
########################################################