#!/bin/bash

# build an image using the Dockerfile
# at the root level of this repo.

# arguments:
# $1 == aws account id
# $2 == aws region
# $3 == ecr repo name

docker build . -t "$1.dkr.ecr.$2.amazonaws.com/$3" -f $(pwd)/Dockerfile
