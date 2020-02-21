Write-Host 'Get Security Permissions'
Write-Host '------------------------'

$server = Read-Host -Prompt 'Enter Server Name'
$folder = Read-Host -Prompt 'Enter Folder Name'

Get-Acl -Path \\$server\$folder | Format-Table -Wrap