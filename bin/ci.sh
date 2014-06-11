#!/bin/bash

set -e

bundle exec micron test/
ret=$?

rake gemspec
diffcount=$(git diff *.gemspec | egrep '^\+')
if [[ $diffcount -gt 2 ]]; then
  echo
  echo "***********************"
  echo "gemspec is out of date!"
  echo "***********************"
  echo
  git diff *.gemspec
  exit 1
fi

# always exit using micron's exit code if we made it this far
exit $ret
