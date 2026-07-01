Get-ChildItem -Path "c:\Mobile\mobile_user\lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_ -Raw
    $modified = $false

    # Update common BoxShadow pattern to new soft shadow
    if ($content -match "BoxShadow\(") {
        # Using a regex replace isn't extremely safe without parsing Dart, but we can try replacing some known patterns.
        # Let's replace Black withOpacity / withValues for shadow.
        $content = [regex]::Replace($content, "BoxShadow\(\s*(?:color:\s*(?:Colors\.black\.(?:withOpacity|withValues)\([^)]+\)|AppColors\.[a-zA-Z]+\.(?:withOpacity|withValues)\([^)]+\)|Color\([^)]+\)\.(?:withOpacity|withValues)\([^)]+\))),?\s*)([^)]*)\)", "BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 6))")
        $modified = $true
    }

    if ($modified) {
        Set-Content $_ -Value $content -Encoding UTF8
    }
}
