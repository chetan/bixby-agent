#!/bin/bash

bundle exec micron test/
ret=$?

set -e

echo -e "\n"
bundle exec rake gemspec
diffcount=$(git diff *.gemspec | egrep '^\+' | wc -l)
if [[ $diffcount -gt 2 ]]; then
  echo
  echo "***********************"
  echo "gemspec is out of date!"
  echo "***********************"
  echo
  git diff *.gemspec | cat -
  exit 1
fi

# always exit using micron's exit code if we made it this far
exit $ret
