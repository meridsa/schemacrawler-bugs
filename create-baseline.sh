#!/bin/bash

function wait_for_db_ready() {
  SLEEP_INTERVAL=10
  sleep $SLEEP_INTERVAL
  # https://unix.stackexchange.com/questions/78512/bash-scripting-loop-until-return-value-is-0
  RES=1
  WAIT_TIME=$SLEEP_INTERVAL
  while [ $RES -ne 0 ]; do
    sleep $SLEEP_INTERVAL
    WAIT_TIME=$((WAIT_TIME + SLEEP_INTERVAL))
    docker exec bughunter-db ./opt/oracle/checkDBStatus.sh 2>&1 > /dev/null
    RES=$?
  done
  echo "Creating image took $WAIT_TIME seconds"
}

docker run --rm --name bughunter-db \
    -p 1556:1521 \
    -v ./setup.sql:/docker-entrypoint-initdb.d/setup/setup.sql \
    -e ORACLE_PWD=bughunter-db \
    oracle/database:18.4.0-xe & \
    wait_for_db_ready

echo DB READY

docker commit -a "Me" -m "Made baseline to avoid waiting for setup" bughunter-db bughunter-db/oracle:18.4.0-xe
echo Created commit

docker stop bughunter-db
