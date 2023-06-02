#!/usr/bin/env bash

set -e

run() {
  printf "\n>> $1 \n\n"
  $1
}
runIfExists() {
  if [ -x "$(command -v $1)" ]; then
    run "$2"
  fi
}


