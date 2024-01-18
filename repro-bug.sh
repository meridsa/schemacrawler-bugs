#!/bin/bash

BUG_CASE=$1
if [[ -z $BUG_CASE ]]; then
  BUG_CASE='enabled-pk'
  echo "No bug case selected. Reproducing $BUG_CASE"
fi


COMPARE_SCHEMAS=false
case "$BUG_CASE" in
  "enabled-pk")
    echo "Reproducing 'enabled-pk' bug" 
    COMPARE_SCHEMAS=true
    COMMAND=schema
    EXPLANATION="In db2 the same primary key has been created in db1, but through enablement instead of in-table creation.\nFixed in Schemacrawler V16.21.1"
    ;;
  *)
    echo "Did not recognise bug case $BUG_CASE"
    exit 1
  ;;
esac

docker stop bughunter-db 2> /dev/null

CONTAINER_ID="$(docker ps -q -f name="bughunter-db")"
while [ -n "$CONTAINER_ID" ];
do
  sleep 1
  echo "Checking if bughunter has stopped"
  CONTAINER_ID="$(docker ps -q -f name="bughunter-db")"
  echo "Is db running: $CONTAINER_ID"
done

sleep 5

docker run --detach --rm --name bughunter-db \
    -p 1556:1521 \
    -v ./$BUG_CASE/create-tables.sql:/opt/oracle/create-tables.sql \
    bughunter-db/oracle:18.4.0-xe

echo "Waiting for bughunter-db to become ready"
docker exec bughunter-db "/opt/oracle/checkDBStatus.sh"

DB_READY=$?
counter=0
while [ $DB_READY -ne 0 ]; do
  sleep 2
  if [ $counter -ge 30 ]; then
    echo "Could not start db in 30 seconds, stopping"
    docker stop bughunter-db
    exit 1
  fi
  counter=$((counter + 1))
  docker exec bughunter-db "/opt/oracle/checkDBStatus.sh"
  DB_READY=$?
done

docker exec bughunter-db sqlplus bughunter/bughunter@XEPDB1 @/opt/oracle/create-tables.sql

schemacrawler.sh \
  --log-level=INFO \
  --server=oracle \
  --host=localhost \
  --port=1556 \
  --database=XEPDB1 \
  --schemas=DB1 \
  --user=db1 \
  --password=db1 \
  --info-level=standard \
  --output-file="$BUG_CASE/db1-schema" \
  --no-info `# This is a comment: Hide Schemacrawler header and database info` \
  --portable-names=true \
  --command=$COMMAND

if [ "$COMPARE_SCHEMAS" = "true" ]; then
  schemacrawler.sh \
    --log-level=INFO \
    --server=oracle \
    --host=localhost \
    --port=1556 \
    --database=XEPDB1 \
    --schemas=DB2 \
    --user=db2 \
    --password=db2 \
    --info-level=standard \
    --output-file="$BUG_CASE/db2-schema" \
    --no-info `# This is a comment: Hide Schemacrawler header and database info` \
    --portable-names=true \
    --command=$COMMAND

  sleep 1
  diff "$BUG_CASE/db1-schema" "$BUG_CASE/db2-schema"
else
  sleep 1
  cat "$BUG_CASE/db1-schema"
fi
echo
printf "Bug explanation: $EXPLANATION"
echo