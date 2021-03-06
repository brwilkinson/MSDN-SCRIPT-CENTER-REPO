$HomeDir = "C:\ps\VMWARE\VMLogs"
Start-Transcript -Path $HomeDir\VMMemoryLog.txt -Append
$SearchString = "MCE"

# Connect-VM is available here: http://bit.ly/nFLHO0
Connect-VM 2
$Now = Get-Date
$myhost = Get-VMHost -State "Connected"

#-----------------------------------------------------
# For the ESX 4.1 Hosts
$LogsVMKernel = Get-VMHost $myhost | foreach-object {
$vmhost = $_.Name
$_
} | where {$_.Version -eq "3.5.0"} | Get-Log vmkernel | Select -expand Entries |  Select-String $SearchString | Foreach {
$hash = @{
VMHostName= $vmhost
MessageLog=$_
}
new-object psobject -Property $hash
}

if ($LogsVMKernel)
    {
        $CurrentVMKernelLogs = $LogsVMKernel | Where-Object {
        $Month,$Day,$Time =  (($_.MessageLog -split " ")[0..2])
        $Then = Get-date (($time[0..4] -join "") + " " + $Day + " " +  $Month)
        (New-TimeSpan -Start $Then -End $Now).TotalMinutes -le 30
        }
        
        if ($CurrentVMKernelLogs)
            {
                # Send-HtmlEmail available here: http://bit.ly/fPzbMO
                Send-HTMLEmail -To Info@domain.org -InputObject $CurrentVMKernelLogs -Subject "Memory Controller Error."
            }
    }

#-----------------------------------------------------
# For the ESX 3.5 Hosts
$LogsVMMessages = Get-VMHost $myhost | foreach-object {
$vmhost = $_.Name
$_
} | Where {$_.version -eq "4.1.0"} | Get-Log messages | Select -expand Entries |  Select-String $SearchString  | Foreach {
$hash = @{
VMHostName= $vmhost
MessageLog=$_
}
new-object psobject -Property $hash
}

if ($LogsVMMessages)
    {
        $CurrentLogsVMMessages = $LogsVMMessages | Where-Object {
            $Month,$Day,$Time =  (($_.MessageLog -split " ")[0..2])
            $Then = Get-date (($time[0..4] -join "") + " " + $Day + " " +  $Month)
            (New-TimeSpan -Start $Then -End $Now).TotalMinutes -le 30
            }
           
        if ($CurrentLogsVMMessages)
            {
                # Send-HtmlEmail available here: http://bit.ly/fPzbMO
                Send-HTMLEmail -To Info@domain.org -InputObject $CurrentLogsVMMessages -Subject "Memory Controller Error."
            }

    
    }

# Disconnect-VM is available here: http://bit.ly/q2Lhmf
Disconnect-vm 2