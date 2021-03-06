function Add-RDCManConfigAzure {

#Requires -Version 3.0
[CmdletBinding()]
 Param 
   (
    [Parameter(Mandatory=$true,
               Position=0)]
    [String]$ResourceGroupName,
    [String]$Template = "$Home\documents\template.rdg"
   )#End Param 

Begin
{
     Write-Verbose "Adding computers to RDCManConfig . . ."
     [XML]$RDCConfig = Get-Content -Path $Template
      
     # Leave the original blank template and save this to a new template with the name of the resoucegroup
     $File = Split-Path -Path $Template -Leaf
     $NewFile = ($File -split "\." | select -First 1) + "_" + $ResourceGroupName + ".rdg"
     $Path = Split-Path -Path $Template
     $NewFilePath = join-path -path $Path -ChildPath $NewFile

     # Backup template file anyway, although it should be blank
     Copy-Item -Path $Template -Destination ($Template -replace '.rdg',("{0:_yyyy-MM-dd_hhmm}.rdg" -f (get-date)))


    $PublicIPs = @{}
    (Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName) | ForEach-Object {

        $a = Split-Path $_.IpConfiguration.ID
        $b = Split-Path $a
        $PublicIPs.Add($_.IpAddress, $b)
    }


    $IPInfo = (Get-AzureRmVM -ResourceGroupName $ResourceGroupName) | ForEach-Object {
    
        $NIC = $_.NetworkProfile.NetworkInterfaces.id -replace "/","\"
        write-warning $NIC
    
        $IP = $PublicIPs.GetEnumerator() | where Value -eq $NIC | foreach Name
    
        [pscustomobject]@{
            VMName           = $_.Name
            ResourceGroupName= $_.ResourceGroupName
            PublicIP         = $IP
            AvailabilitySet  = $_.AvailabilitySetReference.id | split-Path -Leaf -ErrorAction SilentlyContinue
        }

    } | where PublicIP

    $IPInfo

}
Process
{
    
    $IPInfo | Group ResourceGroupName | foreach {
        
          [XML]$ResourceGroup ="    
              <group>
                <properties>
                  <expanded>False</expanded>
                  <name>$($_.Name)</name>
                </properties>
              </group>"
            
            $NewItem = $RDCConfig.ImportNode($ResourceGroup.Group, $true)
            $RDCConfig.RDCMan.file.AppendChild($NewItem)

            $IPInfo | Group AvailabilitySet | foreach {
               $ASName = ($_.Name -split "-")[-1]

              [XML]$AvailabilitySet ="    
                  <group>
                    <properties>
                      <expanded>False</expanded>
                      <name>$ASName</name>
                    </properties>
                  </group>"    
                  
                $NewItem = $RDCConfig.ImportNode($AvailabilitySet.Group, $true)
                $RDCConfig.RDCMan.file.group.AppendChild($NewItem)
                
                $ASName = $_.Name
                $IPInfo | Where AvailabilitySet -EQ $ASName | foreach {

                  [XML]$Server ="    
                        <server>
                          <properties>
                            <displayName>$($_.VMName)</displayName>
                            <name>$($_.PublicIP)</name>
                          </properties>
                        </server>"    
                  
                    $NewItem = $RDCConfig.ImportNode($Server.Server, $true)
                    $RDCConfig.RDCMan.file.group.group.AppendChild($NewItem)                                           
                }#Server
            }#AvailbilitySet
    }#ResourceGroup

    # Save the file to the new name in a new file.
    $RDCConfig.Save($NewFilePath)
 
}

}#Add-RDCManConfigAzure