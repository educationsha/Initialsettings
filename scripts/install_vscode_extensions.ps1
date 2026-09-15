$extensions = Get-Content "$PSScriptRoot\..\vscode\extensions.txt" | Where-Object { $_ -and -not $_.StartsWith("#") }
foreach ($ext in $extensions) { code --install-extension $ext }
