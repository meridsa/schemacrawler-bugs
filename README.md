# README

This repo demonstrates the enabled v. in-table-creation pk bug of schemacrawler.

## Bug description

When a composite primary key is created by using an exisiting unique index schemacrawler is unable to detect it as a primary key.

## Setup

This bug-demo requires that you have the following tools installed `schemacrawler`, `docker`, `diff`.

The base-db-image is created from [Oracle docker SingleInstance](https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance) using the command

`./buildContainerImage.sh -v 18.4.0 -x`

This image creates the baseline image `oracle/database:18.4.0-xe` that `create-baseline.sh` uses.

Baseline creation is separated from creating the tables in the database, as the baseline creation takes a long time. This separation allows quick iteration of table creation.

## Running

Create the base image first with `create-baseline.sh`. Now you can run `bug-repro.sh`. Optionally you may use the folder name to indicate which bug to replicate. This should replicate the bug in the `./$BUG_CASE/db*-schema` files. The \*-pre-comp are the pre-computed schemas to demonstrate the bug.