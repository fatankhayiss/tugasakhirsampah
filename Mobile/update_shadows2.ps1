Get-ChildItem -Path "c:\Mobile\mobile_user\lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_ -Raw
    $modified = $false

    if ($content -match "BoxShadow\(") {
        # Broadly replace blurRadius \d+ with blurRadius: 18, and offset \(\d+, \d+\) with Offset(0, 6)
        $newContent = [regex]::Replace($content, "blurRadius:\s*\d+(?:\.\d+)?", "blurRadius: 18")
        $newContent = [regex]::Replace($newContent, "offset:\s*(?:const\s*)?Offset\([^)]+\)", "offset: const Offset(0, 6)")
        $newContent = [regex]::Replace($newContent, "withValues\(alpha:\s*0\.\d+\)", "withValues(alpha: 0.04)")
        $newContent = [regex]::Replace($newContent, "withOpacity\(0\.\d+\)", "withValues(alpha: 0.04)")
        
        if ($content -ne $newContent) {
           Set-Content $_ -Value $newContent -Encoding UTF8
        }
    }
}
