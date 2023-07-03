#!/bin/bash

# initialize the rds instance
# with a database and a table
# using the `connection_params`
# output from module.rds
# to connect to the DB instance.

mysql $(terraform output -raw connection_params) < ../db/db_init.sql