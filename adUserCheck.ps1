Clear-Host
    
Import-Module -Name ActiveDirectory

$names = get-content "C:\_scripts\aduser-check\adusercheck.txt" 

    foreach ($name in $names) {
            if (Get-ADUser -Filter {sAMAccountName -eq $name }) {
                "$name found in AD" | Out-File "C:\_scripts\aduser-check\Foundchecked.txt" -Append -Verbose
                }
                else { 
                "$name does not exist in AD" | Out-File "C:\_scripts\aduser-check\NotFoundchecked.txt" -Append -Verbose
                }  

            }

