#################################################
# HealthCheck Dashboard
# version 1.2
#################################################

clear-host 

Import-Module UniversalDashboard.Community

###You will need to import the Microsoft Active Directory for some of the dashboard functionality###

Import-Module ActiveDirectory


##Menu Buttons##
$b1 = New-UDButton -Text 'Home' -Icon home -OnClick { Invoke-UDRedirect -Url "/home" }
$b2 = New-UDButton -Text 'Network Check' -Icon network_wired -OnClick { Invoke-UDRedirect -Url "/Network-Check" }
$b3 = New-UDButton -Text 'Security Permission Check' -Icon address_book -OnClick { Invoke-UDRedirect -Url "/Security-Permission-Check" }
################

#####################################
####Starting Page 1 #################
#####################################

$Page1 = New-UDPage -Name "Home" -Icon home -DefaultHomePage -Content {  

####Start Menu####
$b1
$b2
$b3
####End Menu####
    New-UDHtml -Markup "<h5>Server Health Check</h5>"

    New-UDInput -Title "Please Enter Fully Qualified Domain Name of Server: (Example: web.domain.com)" -Endpoint {
            param(
            [Parameter(Mandatory=$true)]
            [string]$RemoteComp 
            )  

    New-UDInputAction  -Content { 

        New-UDElement -Tag 'div'  -Content {

            New-UDLayout  -Columns 4 {
                New-UDCard -title 'Server Name' -Endpoint {$RemoteComp}
                
                New-UDCard -title 'System Time'-Endpoint {Invoke-Command -ComputerName $RemoteComp -ScriptBlock { get-date }} 
                
                New-UDCard -title 'Uptime' -Endpoint {Invoke-Command -ComputerName $RemoteComp -ScriptBlock { Format-Table | systeminfo | find "System Boot Time" }}
              
                New-UDCard -title 'Operating System' -Endpoint {(Get-WmiObject -ComputerName $RemoteComp Win32_OperatingSystem).Caption}

             }

            New-UDLayout  -Columns 3 {

                New-UdMonitor -Title "Memory GB (% committed bytes in use)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
                Get-Counter -ComputerName $RemoteComp '\memory\% committed bytes in use' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
                }

                New-UdMonitor -Title "CPU (% processor time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
                Get-Counter -ComputerName $RemoteComp '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
                }

                New-UDTable -Title 'Hard Disk Space Used/Free GB' -Headers @('Root','Used','Free') -Endpoint {
                Invoke-Command -ComputerName $RemoteComp -ScriptBlock {Get-PSDrive -PSProvider FileSystem | Select-Object 'Root', @{n='Used';e={$_.Used /1GB}}, @{n='Free';e={$_.Free /1GB}}} | Out-UDTableData -Property ('Root','Used','Free')
                }

             }

                New-UDTable -Title 'Network Information' -Headers @('IPAddress','MACAddress', 'IPSubnet', 'DefaultIPGateway', 'DNSServerSearchOrder') -Endpoint {
                Invoke-Command -ComputerName $RemoteComp -ScriptBlock { Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE  | Select-Object -Property `
                @{name='IPAddress'; expression={"  " + $_.IPAddress}}, MACAddress, IPSubnet, DefaultIPGateway , @{name='DNSServerSearchOrder'; expression={"  " + $_.DNSServerSearchOrder}} }`
                | Out-UDTableData -Property ('IPAddress', 'MACAddress', 'IPSubnet', 'DefaultIPGateway', 'DNSServerSearchOrder' )`
                }

            New-UDLayout  -Columns 2 {

                New-UDTable -Title 'Last 20 Application Log Errors' -Headers @('TimeGenerated', 'Source', 'Message') -AutoRefresh -RefreshInterval 60 -Endpoint {
                Invoke-Command -ComputerName $RemoteComp -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 20  | Select-Object TimeGenerated, Source, Message } | Out-UDTableData -Property ('TimeGenerated', 'Source', 'Message')
                }

                New-UDTable -Title 'Last 20 System Log Errors' -Headers @('TimeGenerated',  'Source', 'Message') -AutoRefresh -RefreshInterval 60 -Endpoint {
                Invoke-Command -ComputerName $RemoteComp -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 20  | Select-Object TimeGenerated, Source, Message } | Out-UDTableData -Property ('TimeGenerated', 'Source', 'Message')
                }
            }

        } 
 
    }


}


}
####End Page 1 ######################


#####################################
####Starting Page 2 #################
#####################################
$Page2 = New-UDPage -Name "Network Check" -Icon link -Content { 

####Start Menu####
$b1
$b2
$b3
####End Menu####

#####################################
####Starting ping network tester#####
#####################################

    New-UDHtml -Markup "<h5>Ping Test</h5>" 
    New-UDHtml -Markup "<h6>Please Enter Destination Server Name For The Server You Want To Ping.</h6>" 

            New-UDRow {
                New-UDColumn -Id 'LeftColumn1' -LargeSize 6 -Content {
                
                New-UDCard -Endpoint {
                    New-UDInput -Title '' -Endpoint {
                    param([String]$ping)
                    
                Add-UDElement -ParentId 'RightColumn1' -Content {
                    
                New-UDTable -Title 'Results' -Headers  @('RemoteAddress' , 'InterfaceAlias', 'SourceAddress' , 'PingSucceeded', 'PingReplyDetails') -Endpoint {
                Test-NetConnection -ComputerName $ping | Select-Object `
                @{name = 'RemoteAddress'; expression = { $_.RemoteAddress.ipaddresstostring}}, `
                InterfaceAlias, `
                @{name = 'SourceAddress'; expression={ $_.SourceAddress.ipaddress}}, `
                @{name = 'PingSucceeded'; expression={[String]$_.PingSucceeded}}, `
                @{name = 'PingReplyDetails'; expression={$_.PingReplyDetails.RoundtripTime.ToString() + " ms"}} |  Out-UDTableData -Property @('RemoteAddress' , 'InterfaceAlias', 'SourceAddress' , 'PingSucceeded', 'PingReplyDetails')`
                }
                New-UDHtml -Markup '<button class="btn ud-button" type="button" onClick="window.location.reload();">Reset Page</button>'  
                
                }
                    
                }
                
                }
                }

               New-UDColumn -Id 'RightColumn1' -LargeSize 6 -Content {
               
            }
  
        }

####End ping Network Tester####      

####Starting Super tracerouter#############
###########################################
####TraceRoute                        #####
###########################################

        New-UDHtml -Markup "<h5>TraceRoute</h5>"
        New-UDHtml -Markup "<h6>Please Enter Source and Destination you want to TraceRoute.  Some operating systems may not connect properly and <br> will require logging in to server to complete Traceroute.  Content is displayed when TraceRoute is complete.</h6>" 
        New-UDRow {
           New-UDColumn -Id 'LeftColumn3' -LargeSize 6 -Content {
                New-UDCard -Endpoint {
                    New-UDInput -Title ''  -Endpoint {
                    
                    param([String]$source,
                    [String]$destination
                    )
  
                Add-UDElement -ParentId 'RightColumn3' -Content {               
                
                New-UDElement -Tag 'div' -Endpoint {
               
                $s = New-PSSession -ComputerName $source
                $tresults = (Invoke-Command -Session $s -ScriptBlock { tracert $using:destination }) -join '<br/>'
                Remove-PSSession $s               
                
                
                New-UDCard -Title 'Results'-Content {
                New-UDHtml -Markup $tresults
                }
                } 
               
                           
                New-UDHtml -Markup '<button class="btn ud-button" type="button" onClick="window.location.reload();">Reset Page</button>'
                }
                   
                }
                
                }
                
                }

           New-UDColumn -Id 'RightColumn3' -LargeSize 6 -Content {
           }
        } 

 

}

####End Super tracerouter#####
####End Page 2 ###############

####Start Page 3

$Page3 = New-udpage -Name "Security Permission Check" -Icon link -Content { 

    ####Start Menu####
    $b1
    $b2
    $b3
    ####End Menu####
    
    
    ###########################################
    ####Security Permission Check         #####
    ###########################################

    New-UDHtml -Markup "<h5>Security Permission Check</h5>"
    New-UDHtml -Markup "<h6>Please Enter Server and Folder Name</h6>"
    New-UDInput -Title "Example: For \\server\folder\ Enter Server in the Server Box and Folder in the Folder Box and click Submit" -Endpoint {    
            param(
            [Parameter(Mandatory=$true)]
            [string]$Server,
            [string]$Folder 
            )  


    New-UDInputAction  -Content { 

        New-UDElement -Tag 'div'  -Content {
      

        New-UDTable -Title "Results for Share: \\$server\$folder"  -Headers  @('Owner or Group','Access') -Endpoint {

        $Permissions = (Get-Acl -Path \\$Server\$Folder).Access | 
                           
        ForEach-Object { 
        $_ | Add-Member -MemberType NoteProperty -Name Path -Value \\$Server\$Folder -PassThru }
        
        $Permissions | Select-Object `
        @{name = 'Path'; expression = {Convert-Path $_.Path.ToString() }},
        @{name = 'Owner'; expression = { $_.IdentityReference.ToString() }},
        @{name = 'Access'; expression = { $_.FileSystemRights.ToString() } } | Out-UDTableData -Property @('Owner', 'Access')
        }

        New-UDHtml -Markup '<button class="btn ud-button" type="button" onClick="window.location.reload();">Reset Page</button>'
        }
            
        }
        
    }

}
        
        

####Security Permission Check#######
####End Page 3 #####################

###################################################
#Uncomment below setting to run dashboard in IIS
###################################################


####Create and start Dashboard###

#$Dashboard = New-UDDashboard -Title “Operations Center HealthCheck Dashboard” -Pages @($Page1, $Page2, $Page3) 

#Start-UDDashboard -Wait -Dashboard $Dashboard 



###################################################
#Uncomment out this section to work locally on you
###################################################


####Create and start Dashboard###
$Dashboard = New-UDDashboard -Title "Operations Center HealthCheck Dashboard" -Pages @($Page1, $Page2, $Page3)

Start-UDDashboard -Dashboard $Dashboard -Port 8080 -AutoReload
