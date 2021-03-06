function global:Add-RDCManConfigv2 {

#Requires -Version 2.0
[CmdletBinding(DefaultParameterSetName="AddComputers")]
 Param 
   (
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipeline=$true,
               ParameterSetName="AddComputers",
               ValueFromPipelineByPropertyName=$true)]
    [String[]]$ComputerName,
    [Parameter(Mandatory=$true,
               Position=0,
               ParameterSetName="Query")]
    [Switch]$Query,
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipeline=$false,
               ParameterSetName="AddGroup")]
    [String]$GroupName,
    [String]$Parent,
    [String]$Template = "C:\ps\XML\testfile.rdg",
    [String]$NewTemplate
   )#End Param 

Begin
{
 Write-Verbose "Adding computers to RDCManConfig . . ."
 [XML]$RDCConfig = Get-Content -Path $Template
 # Backup template file
 Copy-Item -Path $Template -Destination ($Template -replace '.rdg',("{0:_yyyy-MM-dd_hhmm}.rdg" -f (get-date)))
}
Process
{
    if ($GroupName)
        {
            [XML]$Group ="    
            <group>
                <properties>
                    <name>$GroupName</name>
                    <expanded>True</expanded>
                    <comment />
                    <logonCredentials inherit='FromParent' />
                    <connectionSettings inherit='FromParent' />
                    <gatewaySettings inherit='FromParent' />
                    <remoteDesktop inherit='FromParent' />
                    <localResources inherit='FromParent' />
                    <securitySettings inherit='FromParent' />
                    <displaySettings inherit='FromParent' />
                </properties>
            </group>"
            
            $NewItem = $RDCConfig.ImportNode($Group.Group, $true)
        }#If(GroupName)                
    elseif ($ComputerName)
        {
            $ComputerName | ForEach-Object {
            $Computer = $_
            [XML]$Server ="
            <server>
                <name>$Computer</name>
                <displayName>$Computer</displayName>
                <comment />
                <logonCredentials inherit='FromParent' />
                <connectionSettings inherit='FromParent' />
                <gatewaySettings inherit='FromParent' />
                <remoteDesktop inherit='FromParent' />
                <localResources inherit='FromParent' />
                <securitySettings inherit='FromParent' />
                <displaySettings inherit='FromParent' />
            </server>"

            $NewItem = $RDCConfig.ImportNode($Server.Server, $true)
            }#Foreach-Object(ComputerName)
        }#if(ComputerName)
        
    if ($Parent)
        {
            If ($RDCConfig.RDCMan.file.group | where-Object {$_.Properties.Name -eq $Parent})
                {
                    if ($NewItem.properties)
                        {
                            'Parent found' | Out-Host
                            'Cannot nest Groups as yet'  | Out-Host
                        }
                    else
                        {
                            'Parent found' | Out-Host
                            $RDCConfig.RDCMan.file.group | 
                            where-Object {$_.Properties.Name -eq $Parent} | 
                            Foreach-Object {$_.AppendChild($NewItem)}
                        }
                }
            elseif ($RDCConfig.RDCMan.file.group | ForEach-Object {$_.group} | Where-Object {$_.properties.name -eq $Parent})
                {
                    'Parent found nested' | Out-Host
                    'Cannot nest as yet'  | Out-Host
                    <#
                    $RDCConfig.RDCMan.file.group | 
                    ForEach-Object {$_.group} | 
                    Where-Object {$_.properties.name -eq $Parent}
                    Foreach-Object {$_.AppendChild($NewItem)}
                    #>
                }
            elseif ($RDCConfig.RDCMan.file.group | ForEach-Object {$_.group} | ForEach-Object {$_.group} | Where-Object {$_.properties.name -eq $Parent})
                {
                    'Parent found nested * 2' | Out-Host
                    'Cannot nest as yet'  | Out-Host
                    <#                    
                    $Parent = $RDCConfig.RDCMan.file.group | 
                    ForEach-Object {$_.group} | 
                    ForEach-Object {$_.group} | 
                    Where-Object {$_.properties.name -eq $Parent} |
                    Foreach-Object {$_.AppendChild($NewItem)}
                    #>
                }
            else
                {
                    'No Parent found' | Out-Host
                    if ($NewItem.properties)
                        {
                            'Adding Group' | Out-Host
                            $RDCConfig.RDCMan.file.AppendChild($NewItem)        
                        }
                    else
                        {
                            try
                                {
                                    $RDCConfig.RDCMan.file.group.AppendChild($NewComputer)
                                }
                            catch
                                {
                                    'You must specify a parent'
                                }
                        }                    
                    
                }
        }#If(Parent)        
    else
        {
            'No Parent specified' | Out-Host
            if ($NewItem.properties)
                {
                    'Adding Group' | Out-Host
                    $RDCConfig.RDCMan.file.AppendChild($NewItem)        
                }
            else
                {
                    try
                        {
                            $RDCConfig.RDCMan.file.group.AppendChild($NewComputer)
                        }
                    catch
                        {
                            'You must specify a parent'
                        }
                }
        }
}
End
{
    if ($NewTemplate)
        {
            $RDCConfig.Save($NewTemplate)
        }
    else 
        {
            $RDCConfig.Save($Template)
        }
}

}#Add-RDCManConfigv2