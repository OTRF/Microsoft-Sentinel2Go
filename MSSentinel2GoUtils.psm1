$scripts = @(Get-ChildItem -Path $PSScriptRoot\resources\scripts\*.ps1 -ErrorAction SilentlyContinue)

foreach ($script in $scripts) {
    try {
        . $script.FullName
    } catch {
        Write-Error "Failed to import $($script.FullName): $_"
    }
}