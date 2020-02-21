clear-host
$names = get-content C:\_scripts\aduser-check\adUserCheck.txt


foreach ($name in $names) {
Get-ADUser -Identity $name -Properties “LastLogonDate” | Select-Object GivenName,Surname,Name, LastLogonDate

}