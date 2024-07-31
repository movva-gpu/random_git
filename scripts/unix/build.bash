#! /bin/bash

if ! which gleam &> /dev/null
then
    echo "Please install gleam first: https://gleam.run/getting-started/installing/"
    exit
fi

if ! which bun &> /dev/null
then
    echo "Please install bun first: https://bun.sh/"
    exit
fi

gleam clean &&
gleam deps download &&

bun install --frozen-lockfile &&

gleam build -t javascript &&
bun build ./build/dev/javascript/random_git/random_git.mjs --minify --target node --outfile ./dist/randomgit.mjs &&
bun build ./src/runner.mjs --minify --target node --outfile ./dist/runner.mjs &&

rm -f ./dist/randomgit.mjs &&
mv ./dist/runner.mjs ./dist/randomgit.mjs
