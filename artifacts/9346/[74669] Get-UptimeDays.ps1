function global:Get-UptimeDays {

#Requires -Version 2.0
[CmdletBinding(DefaultParametersetName="ComputerName")]
 Param 
   (
    [Parameter(Mandatory=$true,
               Position=1,
               ParameterSetName="HostFile",
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String]$HostFile,
    [Parameter(Mandatory=$true,
               Position=1,
               ParameterSetName="ComputerName",   
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String[]]$ComputerName,    
    [Switch]$Mail,
    [Switch]$Text,
    [String]$Path,
    [String]$TO = "users@domain.org",
    [String]$FROM = "admin@domain.org",
    [String]$SMTP = "relay.domain.org",
    [String]$Subject = "Server Uptime Report $(get-date)"       
   )#End Param 

Begin
{
 Write-Host "Retrieving Uptime Info . . ." -nonewline
}
Process
{
switch ($PsCmdlet.ParameterSetName) 
    { 
    "HostFile"  {$Servers = (Get-Content $HostFile)} 
    "ComputerName"  {$Servers = $ComputerName} 
    }
$UptimeReport = $Servers | ForEach-Object {
$ErrorActionPreference = 0
$wmi=Get-WmiObject -Class Win32_OperatingSystem -ComputerName $_
$ErrorActionPreference = 1
if ($wmi -ne $Null)
{
$ErrorActionPreference = "silentlycontinue"
$LBTime=$wmi.ConvertToDateTime($wmi.Lastbootuptime)
[TimeSpan]$uptime=New-TimeSpan $LBTime $(get-date)
New-Object PSObject -Property @{ 
Server=$_
Uptime="----->"
Days=$uptime.days
Hours=$uptime.hours
Minutes=$uptime.minutes
Seconds=$uptime.seconds
}
$wmi=$null
}
}
if ($Text)
    {
        Get-Date | Out-Host
        $Report = $UptimeReport | Select-Object Server,Uptime,Days,hours,minutes,seconds |
        Sort-Object Days -Descending 
        $Report | Format-Table -AutoSize
    }
elseif ($Path)
    {
        $UptimeReport | Select-Object Server,Uptime,Days,hours,minutes,seconds |
        Sort-Object -Property Days -Descending | 
        Export-Csv -Path $Path -NoTypeInformation
        write-host "Report exported to:" $Path  
    }
else
    {
        Get-Date | Out-Host
        $Report = $UptimeReport | Select-Object Server,Uptime,Days | sort-object Days -Descending 
        $textreport = $report | ft -AutoSize
        $textreport
    }
if ($Mail)
{
    Send-HTMLEmail -InputObject $Report -Subject $Subject -To $To
}
}
End
{
$Hostlist = $Null
$Hostname = $Null
}

}
