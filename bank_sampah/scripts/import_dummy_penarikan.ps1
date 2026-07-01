# import_dummy_penarikan.ps1
# PowerShell helper to import db_add_dummy_penarikan.sql into a database (Laragon/Windows)
# Usage: .\import_dummy_penarikan.ps1 -DbName db_banksampah_dummy -User root
param(
    [string]$DbName = "db_banksampah_dummy",
    [string]$User = "root",
    [string]$SqlFile = "C:\laragon\www\bank_sampah\db_add_dummy_penarikan.sql"
)

Write-Host "About to import '$SqlFile' into database '$DbName' as user '$User'."
$pass = Read-Host -AsSecureString "Enter MySQL password for user $User (input hidden)"
$plainPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))

# Build command
$mysqlCmd = "mysql --user=$User --password=$plainPass $DbName < `"$SqlFile`""
Write-Host "Running import... (command will be executed via cmd.exe because redirection is used)"
cmd /c $mysqlCmd
if ($LASTEXITCODE -eq 0) {
    Write-Host "Import completed successfully." -ForegroundColor Green
} else {
    Write-Host "Import may have failed. Exit code: $LASTEXITCODE" -ForegroundColor Red
}

# Clear sensitive variable
$plainPass = ""
Remove-Variable pass -ErrorAction SilentlyContinue
