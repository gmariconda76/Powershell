Clear-Host

$servers = @(

"alpvwofsoas01.corpstg1.jmfamily.com",
"alpvwofsoap01.corp.jmfamily.com",
"chivwofsoap01.corp.jmfamily.com",
"CHVJMMWSQL003BP.corp.jmfamily.com",
"ALVJMSWADM001AP.corp.jmfamily.com",
"ALPVJMSCMBLP01.corp.jmfamily.com",
"chivjmscadmp01.corp.jmfamily.com",
"ALVJMMWSQL003AP.corp.jmfamily.com",
"chvjmmwsql018bp.corp.jmfamily.com",
"CHVJMAWSQL001BP.corp.jmfamily.com",
"CHVJMFWSQL004AP.corp.jmfamily.com",
"ALVSETWAPP301BS.corpstg1.jmfamily.com"

)

    ForEach ($server in $servers) {
    
    $getos = (Get-WmiObject -ComputerName $server Win32_OperatingSystem).caption
    Write-Host "$server is running $getos"
    
}
