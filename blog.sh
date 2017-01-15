#!/bin/sh
#You Can set the program name and config file name below:
RED=\\e[1m\\e[31m
DARKRED=\\e[31m
GREEN=\\e[1m\\e[32m
DARKGREEN=\\e[32m
BLUE=\\e[1m\\e[34m
DARKBLUE=\\e[34m
YELLOW=\\e[1m\\e[33m
DARKYELLOW=\\e[33m
MAGENTA=\\e[1m\\e[35m
DARKMAGENTA=\\e[35m
CYAN=\\e[1m\\e[36m
DARKCYAN=\\e[36m
RESET=\\e[m

if [ $# != 1 ]
then
	echo -e "$RED USAGE: $0 $YELLOW option [start | stop | restart | heartbeat]$RESET"
	exit 0;
fi

if [ $1 = "heartbeat" ]
then
	while true
	do
		pidnum=`ps -ef|grep "hexo"|grep -v grep|wc -l`
		if [ $pidnum -lt 1 ]
		then
			nohup hexo server &	
		fi
		sleep 1
	done
fi

