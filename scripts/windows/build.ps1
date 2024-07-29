#!powershell

if (!(Get-Command "gleam" -ErrorAction SilentlyContinue)) {
    Write-Host "Please install gleam first: https://gleam.run/getting-started/installing/"
    exit 1
}

if (!(Get-Command "bun" -ErrorAction SilentlyContinue)) {
    Write-Host "Please install bun first: https://bun.sh/"
    exit 1
}

gleam clean;

if ($?) { gleam deps download }

if ($?) { bun install --frozen-lockfile }

if ($?) { gleam build -t javascript }
if ($?) { bun build .\build\dev\javascript\random_git\random_git.mjs --target node --outfile .\dist\randomgit.mjs }
if ($?) { bun build .\src\runner.mjs --minify --target node --outfile .\dist\runner.mjs };

if ($?) { Remove-Item -Force -Path .\dist\randomgit.mjs }
if ($?) { Rename-Item -Force -Path .\dist\runner.mjs -NewName randomgit.mjs }
