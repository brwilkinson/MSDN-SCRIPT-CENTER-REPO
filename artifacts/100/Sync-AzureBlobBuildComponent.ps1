#requires -Module Az.Storage
#requires -Module Az.Accounts

<#
.SYNOPSIS
    Stage Files from a Build on Azure Storage (Blob Container), for Deployment
.DESCRIPTION
    Stage Files from a Build on Azure Storage (Blob Container), for Deployment. Primarily used for a PULL mode deployment where a Server can retrieve new builds via Desired State Configuration.
.EXAMPLE
    Sync-AzureBlobBuildComponent -ComponentName WebAPI -BuildName 5.3 -BasePath "F:\Builds\WebAPI"

    Sync a local Build
.EXAMPLE
    Sync-AzureBlobBuildComponent -ComponentName $(ComponentName) -BuildName $(Build.BuildNumber) -BasePath "$(System.ArtifactsDirectory)/_$(ComponentName)/$(ComponentName)"

    As seen in an Azure DevOps pipeline
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Updated 04/03/2021 
        - Moved the script from using Storage File Shares to Storage Blob Containers

    Updated 02/16/2021 
        - Added to Function instead of Script
        - Added examples
        - Updated to work with the newer AZ.Storage Module tested with 3.2.1
#>

function Sync-AzureBlobBuildComponent
{
    Param (
        [String]$BuildName = '4.2',
        [String]$ComponentName = 'LogHeadersAPI',
        [String]$BasePath = 'D:\Builds'
    )

    # Azure Blob Container Info
    [String]$SAName = 'saeastus2build'
    [String]$RGName = 'rgglobalbuild'
    [String]$ContainerName = 'builds'

    # if you already have a storage account you can get the context
    $SA = Get-AzStorageAccount -ResourceGroupName $RGName -Name $SAName

    $StorageContainerParams = @{
        Container   = $ContainerName
        Context     = $SA.Context
        ErrorAction = 'SilentlyContinue'
    }

    # *Builds/<ComponentName>/<BuildName>
    # need to pass this in
    $CurrentFolder = (Get-Item -Path $BasePath\$ComponentName\$BuildName ).FullName

    # Copy up the files and capture a list of the files URI's
    $SourceFiles = Get-ChildItem -Path $BasePath\$ComponentName\$BuildName -File -Recurse | ForEach-Object {
        $path = $_.FullName.Substring($Currentfolder.Length + 1).Replace('\', '/')
        Write-Output -InputObject "$ComponentName/$BuildName/$path"
        $b = Set-AzStorageBlobContent @StorageContainerParams -File $_.FullName -Blob $ComponentName\$BuildName\$Path -Verbose -Force
    }

    # Find all of the files in the share including subfolders
    $Path = "$ComponentName/$BuildName/*"
    $DestinationFiles = Get-AzStorageBlob @StorageContainerParams -Blob $Path | Foreach Name

    # Compare the new files that were uploaded to the files already on the share
    # these should be deleted from the Azure Blob Container
    $FilestoRemove = Compare-Object -ReferenceObject $DestinationFiles -DifferenceObject $SourceFiles -IncludeEqual | 
        Where-Object SideIndicator -EQ '<=' | ForEach-Object InputObject

    # Remove the old Files
    $FilestoRemove | ForEach-Object {
        Write-Verbose "Removing: [$_]" -Verbose
        Remove-AzStorageBlob @StorageContainerParams -Blob "$_" -Verbose
    }
}