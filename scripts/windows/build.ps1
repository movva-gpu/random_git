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
bun build .\build\dev\javascript\random_git\random_git.mjs --target bun --outfile .\dist\randomgit.mjs
bun build .\dist\randomgit.mjs --minify --target bun --outfile .\dist\randomgit.min.mjs;

Copy-Item .\dist\randomgit.mjs .\build.tmp
Write-Output "main();" >> .\build.tmp

bun build --compile .\build.tmp --target bun-windows-x64 --outfile .\dist\randomgit.exe --minify

Remove-Item -Force .\build.tmp
