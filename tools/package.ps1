# Builds a release zip for Nexus/GitHub: dist\HshKbm-<version>.zip
# Layout inside the zip mirrors the game folder, so users extract it over the game root (after installing BepInEx 5 x86).
$ErrorActionPreference = "Stop"
$root = Resolve-Path "$PSScriptRoot\.."
$proj = "$root\src\HshKbm\HshKbm.csproj"
$version = ([xml](Get-Content $proj)).Project.PropertyGroup.Version | Where-Object { $_ } | Select-Object -First 1

Set-Location "$root\src\HshKbm"
dotnet build -c Release --nologo -v minimal -p:SkipDeploy=true | Out-Null
$dll = "$root\src\HshKbm\bin\Release\netstandard2.1\HshKbm.dll"
if (-not (Test-Path $dll)) { throw "build failed: $dll missing" }

$stage = "$root\dist\stage"
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
$plugin = "$stage\BepInEx\plugins\HshKbm"
New-Item -ItemType Directory -Force "$plugin\keys" | Out-Null
Copy-Item $dll $plugin
Copy-Item "$root\assets\keys\*.png" "$plugin\keys"
Copy-Item "$root\assets\keys\*.json" "$plugin\keys"
Copy-Item "$root\README.md" "$stage\HshKbm-README.md"
Copy-Item "$root\LICENSE" "$stage\HshKbm-LICENSE.txt"

$zip = "$root\dist\HshKbm-$version.zip"
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Compress-Archive -Path "$stage\*" -DestinationPath $zip
Remove-Item $stage -Recurse -Force
Write-Host "wrote $zip"
