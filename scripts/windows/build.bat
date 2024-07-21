@echo off

where gleam >nul 2>nul
if %errorlevel% neq 0 (
    echo Please install gleam first: https://gleam.run/getting-started/installing/
    pause
    exit 1
)

where bun >nul 2>nul
if %errorlevel% neq 0 (
    echo Please install bun first: https://bun.sh/
    pause
    exit 1
)

gleam build -t javascript
bun build ".\build\dev\javascript\random_git\random_git.mjs" --target bun --outfile ".\dist\randomgit.mjs"
bun build ".\dist\randomgit.mjs" --minify --target bun --outfile ".\dist\randomgit.min.mjs"

copy /b ".\dist\randomgit.mjs" ".\build.tmp"
echo main(); >> ".\build.tmp"

bun build --compile ".\build.tmp" --target bun-windows-x64 --outfile ".\dist\randomgit.exe" --minify

del ".\build.tmp"
