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

gleam clean && ^
gleam deps download && ^
bun install --frozen-lockfile && ^
gleam build -t javascript && ^
bun build ".\build\dev\javascript\random_git\random_git.mjs" --target bun --outfile ".\dist\randomgit.mjs" && ^
bun build ".\src\runner.mjs" --minify --target bun --outfile ".\dist\runner.mjs" && ^
del ".\dist\randomgit.mjs" && ^
ren ".\dist\runner.mjs" "randomgit.mjs"
