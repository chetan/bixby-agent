#!/bin/bash

set -e

if [[ ! -d repo ]]; then
  mkdir repo
  cd repo
  git clone https://github.com/chetan/bixby-repo.git vendor
  cd ..
fi
