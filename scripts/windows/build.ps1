#!powershell

if (!(Get-Command "gleam" -ErrorAction SilentlyContinue)) {
    Write-Host "Please install gleam first: https://gleam.run/getting-started/installing/"
    exit 1
}

if (!(Get-Command "bun" -ErrorAction SilentlyContinue)) {
    Write-Host "Please install bun first: https://bun.sh/"
    exit 1
}

gleam build -t javascript
bun build .\build\dev\javascript\random_git\random_git.mjs --target node --outfile .\dist\randomgit.mjs
bun build .\src\runner.mjs --minify --target node --outfile .\dist\runner.mjs;
