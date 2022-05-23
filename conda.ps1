#!/usr/bin/pwsh
#Requires -PSEdition Core
<#
.SYNOPSIS
Script for managing conda environments.
.EXAMPLE
./conda.ps1 -o 'create'         # *Create/update environment
./conda.ps1 -o 'activate'       # *Activate environment
./conda.ps1 -o 'deactivate'     # *Deactivate environment
./conda.ps1 -o 'packages'       # *List packages
./conda.ps1 -o 'environments'   # *List environments
./conda.ps1 -o 'update'         # *Update conda
./conda.ps1 -o 'clean'          # *Clean conda
./conda.ps1 -o 'remove'         # !Remove environment

$CondaFile = 'environment.yml'
./conda.ps1 -f $CondaFile -o 'create'   # *Create/update environment
./conda.ps1 -f $CondaFile -o 'activate' # *Activate environment
./conda.ps1 -f $CondaFile -o 'remove'   # !Remove environment
#>
[CmdletBinding()]
param (
    [Alias('o')]
    [Parameter(Mandatory)]
    [ValidateSet('create', 'activate', 'deactivate', 'packages', 'environments', 'clean', 'update', 'remove')]
    [string]$Option,

    [Alias('f')]
    [ValidateNotNullorEmpty()]
    [string]$CondaFile = 'conda.yaml'
)

# *Check mamba installation
if ($Option -in @('create', 'clean', 'update')) {
    $mamba = $env:CONDA_EXE -replace ('\bconda', 'mamba')
    if (-not (Test-Path $mamba)) {
        Write-Host 'mamba not found, installing...'
        Invoke-Conda install --name base --channel conda-forge mamba
    }
}

if ($Option -in @('create', 'activate', 'remove')) {
    if (-not (Test-Path $CondaFile)) {
        Write-Warning "File `e[4m$CondaFile`e[24m not found"
        break
    }

    # get environment name
    $envName = (Select-String -Pattern '^name: +(\S+)' -Path $CondaFile).Matches.Groups[1].Value
    $envExists = $envName -in (Get-CondaEnvironment).Name 2>$null

    # exit environment before proceeding
    Exit-CondaEnvironment
    if ($envExists) {
        switch ($Option) {
            { $_ -eq 'create'} {
                # *Create environment
                Write-Host "`nEnvironment `e[1;4m$envName`e[22;24m already exist. Updating..."
                & $mamba env update --file $CondaFile --prune 2>$null
                Enter-CondaEnvironment $envName
                break
            }
            { $_ -eq 'activate'} {
                # *Activate environment
                Enter-CondaEnvironment $envName
                break
            }
            { $_ -eq 'remove'} {
                # *Remove environment
                Write-Host "Removing `e[1;4m$envName`e[22;24m environment."
                Invoke-Conda env remove --name $envName 2>$null
                break
            }
        }
    } elseif ($Option -eq 'create') {
        # *Update environment
        Write-Host "Creating `e[1;4m$envName`e[22;24m environment."
        & $mamba env create --file $CondaFile 2>$null
        Enter-CondaEnvironment $envName
    } else {
        Write-Warning "`e[1;4m$envName`e[22;24m environment not found"
    }
} else {
    switch ($Option) {
        { $_ -eq 'deactivate'} {
            # *Clean conda
            Exit-CondaEnvironment
            break
        }
        { $_ -eq 'packages'} {
            # *List packages
            Invoke-Conda list
            break
        }
        { $_ -eq 'environments'} {
            # *List environments
            Invoke-Conda env list 2>$null
            break
        }
        { $_ -eq 'update'} {
            # *Update conda
            & $mamba update --name base --channel conda-forge --update-all 2>$null
            break
        }
        { $_ -eq 'clean'} {
            # *Clean conda
            & $mamba clean --all 2>$null
            break
        }
    }
}
