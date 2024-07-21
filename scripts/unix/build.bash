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

gleam build -t javascript
bun build ./build/dev/javascript/random_git/random_git.mjs --target bun --outfile ./dist/randomgit.mjs
bun build ./dist/randomgit.mjs --minify --target bun --outfile ./dist/randomgit.min.mjs;

cp ./dist/randomgit.mjs ./build.tmp
echo "main();" >> ./build.tmp

bun build --compile ./build.tmp --outfile ./dist/randomgit --target bun-linux-x64 --minify

rm -f ./build.tmp
