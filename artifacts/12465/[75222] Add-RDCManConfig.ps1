function global:Add-RDCManConfig {

#Requires -Version 2.0
[CmdletBinding()]
 Param 
   (
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String[]]$ComputerName,
    [String]$Template = "C:\ps\XML\RDCTemplate.rdg",
    [String]$NewTemplate = "C:\ps\XML\RDCTemplateUpdate.rdg"
   )#End Param 

Begin
{
 Write-Verbose "Adding computers to RDCManConfig . . ."
 [XML]$RDCConfig = Get-Content -Path $Template
}
Process
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

    $New = $RDCConfig.ImportNode($Server.Server, $true)
    $RDCConfig.RDCMan.file.group.AppendChild($New)
    }#Foreach-Object(ComputerName)
}
End
{
    $RDCConfig.Save($NewTemplate)
}

}#Add-RDCManConfig