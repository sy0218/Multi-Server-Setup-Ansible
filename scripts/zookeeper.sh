#!/usr/bin/bash
. /work/jsy/scripts/functions.sh
. /work/jsy/scripts/conf/server.properties

# 인자가 없거나 공백이면 종료
if [ -z "$1" ]; then
    echo "${0} 인자가 없습니다. 스크립트를 종료합니다. (ex. start, stop, status)"
    exit 1
fi

ZK_OPT=${1}
ZK_bin="${ZOOKEEPER_HOME}/bin"

for ip in ${zookeeper_ip}
do
	log_info "[Zookeeper] ${ip} start ${ZK_OPT}"
	ssh ${ip} ${ZK_bin}/zkServer.sh ${ZK_OPT}
	log_info "[Zookeeper] ${ip} end   ${ZK_OPT}"
	echo
	echo
done
