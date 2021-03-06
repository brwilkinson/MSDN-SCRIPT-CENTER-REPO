function Update-FileRepository {
param (
        $NewFilesPath = "\\Server\files\LatestFilesDir",
        $CurrentPath = "$SkyDrive\MyFilesDir",
        [Switch]$Force
       )

if (!(Test-Path -Path $NewFilesPath))
    {
        "You need to be on the Network, cannot connect to $NewFilesPath"
    }
else
    {
        $NewFiles = (Get-ChildItem $NewFilesPath)
        $OldFiles = (Get-ChildItem $CurrentPath)      
        
        
        $NewFiles | ForEach-Object {

        $CurrentNewFile = $_

        if (($OldFiles | Select-Object -ExpandProperty Name) -contains $CurrentNewFile.Name)
            {
                $OldFiles | Where-Object { $_.Name -EQ $CurrentNewFile.Name } | ForEach-Object {
                    if ($_.lastwritetime -lt $CurrentNewFile.LastWriteTime)
                        {
                            Copy-Item $CurrentNewFile.FullName -Destination $CurrentPath -Verbose -Force
                        }
                    else
                        {
                            Write-Host "$CurrentNewFile.Name already exists"
                        }        

                }
            }
        else
            {
                Copy-Item $CurrentNewFile.FullName -Destination $CurrentPath -Verbose
            }

        }
    }

}#Update-FileRepository

