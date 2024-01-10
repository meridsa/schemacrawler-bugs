#!/bin/bash

docker stop bughunter-db

set -e

docker run --rm --name bughunter-db \
    -p 1556:1521 \
    -v ./create-tables.sql:/opt/oracle/create-tables.sql \
    bughunter-db/oracle:18.4.0-xe & sleep 30

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
  --output-file="db1-schema" \
  --no-info `# This is a comment: Hide Schemacrawler header and database info` \
  --portable-names=true \
  --command=schema

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
  --output-file="db2-schema" \
  --no-info `# This is a comment: Hide Schemacrawler header and database info` \
  --portable-names=true \
  --command=schema

echo
echo ---------- diff db1-schema db2-schema ----------
echo

diff db1-schema db2-schema

