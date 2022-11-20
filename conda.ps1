#!/usr/bin/env pwsh
#Requires -PSEdition Core
<#
.SYNOPSIS
Script for managing conda environments.
.PARAMETER Option
Select script action.
.PARAMETER CondaFile
Specify conda file to use.

.EXAMPLE
./conda.ps1                     # *Create/update environment
./conda.ps1 -o 'activate'       # *Activate environment
./conda.ps1 -o 'deactivate'     # *Deactivate environment
./conda.ps1 -o 'packages'       # *List packages
./conda.ps1 -o 'environments'   # *List environments
./conda.ps1 -o 'update'         # *Update conda
./conda.ps1 -o 'clean'          # *Clean conda
./conda.ps1 -o 'remove'         # !Remove environment

$CondaFile = '.tmp/env.yml'
./conda.ps1 -f $CondaFile               # *Create/update environment
./conda.ps1 -f $CondaFile -o 'activate' # *Activate environment
./conda.ps1 -f $CondaFile -o 'remove'   # !Remove environment
#>
[CmdletBinding()]
param (
    [Alias('o')]
    [ValidateSet('create', 'activate', 'deactivate', 'packages', 'environments', 'clean', 'update', 'remove')]
    [string]$Option = 'create',

    [Alias('f')]
    [ValidateNotNullorEmpty()]
    [string]$CondaFile = 'conda.yaml'
)

# *Check for conda file
if ($Option -in @('create', 'activate', 'remove')) {
    if (Test-Path $CondaFile) {
        # get environment name
        $envName = (Select-String -Pattern '^name: +(\S+)' -Path $CondaFile).Matches.Groups[1].Value
        $envExists = $envName -in (Get-CondaEnvironment).Name
        # exit environment before proceeding
        Exit-CondaEnvironment
    } else {
        Write-Warning "File `e[4m$CondaFile`e[24m not found"
        exit
    }
}

# *Execute option
switch ($Option) {
    'create' {
        # check libmamba solver installation
        if (-not (Get-ChildItem -Path "$env:_CONDA_ROOT/pkgs/" -Filter 'conda-libmamba-solver*' -Directory)) {
            Write-Host 'conda-libmamba-solver not found, installing...'
            Invoke-Conda install -y --name base --channel pkgs/main 'conda-libmamba-solver'
        }
        if ($envExists) {
            # *Create environment
            Write-Host "`nEnvironment `e[1;4m$envName`e[22;24m already exist. Updating..."
            $cmd = "conda env update --file $CondaFile --prune$($envName -eq 'base' ? '' : ' --experimental-solver=libmamba')"
            Invoke-Expression $cmd
            Enter-CondaEnvironment $envName
        } else {
            # *Update environment
            Write-Host "Creating `e[1;4m$envName`e[22;24m environment."
            conda env create --file $CondaFile --experimental-solver=libmamba
            Enter-CondaEnvironment $envName
        }
        break
    }

    'activate' {
        # *Activate environment
        if ($envExists) {
            Enter-CondaEnvironment $envName
        } else {
            Write-Host "`e[1;4m$envName`e[22;24m environment doesn't exist!"
        }
        break
    }

    'remove' {
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

    'deactivate' {
        # *Clean conda
        Exit-CondaEnvironment
        break
    }

    'packages' {
        # *List packages
        Invoke-Conda list
        break
    }

    'environments' {
        # *List environments
        Invoke-Conda env list
        break
    }

    'update' {
        # *Update conda
        conda update -y --name base --channel pkgs/main --update-all
        break
    }

    'clean' {
        # *Clean conda
        conda clean -y --all
        break
    }
}
