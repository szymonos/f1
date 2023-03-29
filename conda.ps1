#!/usr/bin/env pwsh
#Requires -PSEdition Core
<#
.SYNOPSIS
Script for managing conda environments.
.PARAMETER Option
Select script action.
.PARAMETER CondaFile
Specify path to conda file to be used for creating environment.

.EXAMPLE
./conda.ps1                           # *Displays help page
./conda.ps1 setup                     # *Create/update environment
./conda.ps1 activate                  # *Activate environment
./conda.ps1 deactivate                # *Deactivate environment
./conda.ps1 list                      # *List packages
./conda.ps1 envs                      # *List environments
./conda.ps1 update                    # *Update conda
./conda.ps1 clean                     # *Clean conda
./conda.ps1 remove                    # !Remove environment

$CondaFile = '.tmp/env.yml'
./conda.ps1 -f $CondaFile             # *Create/update environment
./conda.ps1 -f $CondaFile -o activate # *Activate environment
./conda.ps1 -f $CondaFile -o remove   # !Remove environment
#>
[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [string]$Option,

    [Alias('f')]
    [ValidateNotNullorEmpty()]
    [string]$CondaFile = 'conda.yaml'
)

dynamicparam {
    if (@('activate', 'remove') -match "^$Option" -and -not $PSBoundParameters.CondaFile) {
        $parameterAttribute = [Management.Automation.ParameterAttribute]@{ Position = 1 }

        $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
        $attributeCollection.Add($parameterAttribute)

        $dynParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
            'Environment', [string], $attributeCollection
        )

        $paramDict = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        $paramDict.Add('Environment', $dynParam)
        return $paramDict
    }
}

begin {
    if (-not $Option) {
        [Console]::WriteLine(
            [string]::Join("`n",
                "Script for managing conda environments.`n",
                "usage: conda.ps1 [-Option] <string> [[-Environment] <string>] [-CondaFile <string>]`n",
                'The following options are available:',
                "  `e[1;97mactivate`e[0m    Activate environment",
                "  `e[1;97mclean`e[0m       Clean conda environment",
                "  `e[1;97mdeactivate`e[0m  Deactivate environment",
                "  `e[1;97menvs`e[0m        List environments",
                "  `e[1;97mlist`e[0m        List packages",
                "  `e[1;97mremove`e[0m      Remove environment",
                "  `e[1;97msetup`e[0m       Create/update environment",
                "  `e[1;97mupdate`e[0m      Update conda`n"
            )
        )
        return
    }
    # evaluate Option parameter abbreviations
    $optSet = @('activate', 'clean', 'deactivate', 'envs', 'list', 'remove', 'setup', 'update')
    $opt = $optSet -match "^$Option"
    if ($opt.Count -eq 0) {
        Write-Warning "Option parameter name '$Option' is invalid. Valid Option values are:`n`t $($optSet -join ', ')"
        break
    } elseif ($opt.Count -gt 1) {
        Write-Warning "Option parameter name '$Option' is ambiguous. Possible matches include: $($opt -join ', ')."
        break
    }

    # check for conda file
    if ($opt -in @('activate', 'remove', 'setup')) {
        if ($PSBoundParameters.Environment) {
            $envName = $PSBoundParameters.Environment
            $envExists = $true
        } elseif (Test-Path $CondaFile) {
            # get environment name
            $envName = (Select-String -Pattern '^name: +(\S+)' -Path $CondaFile).Matches.Groups.Where({ $_.Name -eq '1' }).Value
            $envExists = $envName -in (Get-CondaEnvironment).Name
        } else {
            Write-Warning "File `e[4m$CondaFile`e[24m not found"
            break
        }
        if ($envName) {
            # exit environment before proceeding
            Exit-CondaEnvironment
        }
    }
}

# *Execute option
process {
    switch ($opt) {
        activate {
            # *Activate environment
            if ($envExists) {
                Enter-CondaEnvironment $envName
            } else {
                Write-Host "`e[1;4m$envName`e[22;24m environment doesn't exist!"
            }
            break
        }

        clean {
            # *Clean conda
            Invoke-Conda clean -y --all
            break
        }

        deactivate {
            # *Clean conda
            Exit-CondaEnvironment
            break
        }

        envs {
            # *List environments
            Invoke-Conda env list
            break
        }

        list {
            # *List packages
            Invoke-Conda list
            break
        }

        remove {
            # *Remove environment
            if ($envName -eq 'base') {
                Write-Host "Cannot remove `e[1;4mbase`e[22;24m environment!"
            } elseif ($envExists) {
                Write-Host "Removing `e[1;4m$envName`e[22;24m environment."
                Invoke-Conda env remove --name $envName
            } else {
                Write-Host "`e[1;4m$envName`e[22;24m environment doesn't exist!"
            }
            break
        }

        setup {
            if ($envExists) {
                # *Create environment
                Write-Host "`nEnvironment `e[1;4m$envName`e[22;24m already exist. Updating..."
                Invoke-Conda env update --file $CondaFile --prune
                Enter-CondaEnvironment $envName
            } else {
                # *Update environment
                Write-Host "Creating `e[1;4m$envName`e[22;24m environment."
                Invoke-Conda env create --file $CondaFile
                Enter-CondaEnvironment $envName
            }
            break
        }

        update {
            # *Update conda
            Invoke-Conda update -y --name base --channel pkgs/main --update-all
            break
        }

    }
}
