#!/usr/bin/pwsh
#Requires -PSEdition Core
<#
.SYNOPSIS
Script for managing conda environments.
.EXAMPLE
./conda.ps1     # *Create/update environment
./conda.ps1 -a  # *Activate environment
./conda.ps1 -d  # *Deactivate environment
./conda.ps1 -l  # *List packages
./conda.ps1 -e  # *List environments
./conda.ps1 -c  # *Clean conda
./conda.ps1 -u  # *Update conda
./conda.ps1 -r  # !Remove environment
#>
[CmdletBinding()]
param (
    [Alias('a')][switch]$ActivateEnv,
    [Alias('d')][switch]$DeactivateEnv,
    [Alias('l')][switch]$ListPackages,
    [Alias('e')][switch]$ListEnv,
    [Alias('c')][switch]$CondaClean,
    [Alias('u')][switch]$CondaUpdate,
    [Alias('r')][switch]$RemoveEnv
)

# const
$ENV_FILE = 'conda.yaml'
# calculate script variables
$envName = (Select-String -Pattern '^name: +(\S+)' -Path $ENV_FILE).Matches.Groups[1].Value
$isActivEnv = $null -ne $env:CONDA_DEFAULT_ENV -and -not $DeactivateEnv -and -not $RemoveEnv
if (-not $PSBoundParameters.Count -or $RemoveEnv) {
    $envExists = $envName -in (Get-CondaEnvironment).Name
}

# *Deactivate environment
if (-not ($ListPackages -or $ListEnv)) {
    Exit-CondaEnvironment
}

# *Check mamba installation
if (-not $PSBoundParameters.Count -or $CondaClean -or $CondaUpdate) {
    $mamba = $env:CONDA_EXE -replace ('\bconda', 'mamba')
    if (-not (Test-Path $mamba)) {
        Write-Host 'mamba not found, installing...'
        Invoke-Conda install --name base --channel conda-forge mamba
    }
}

# *Create/update environment
if (-not $PSBoundParameters.Count) {
    if ($envExists) {
        $msg = "`nEnvironment `e[1;4m$envName`e[0m already exists.`nProceed to update ([y]/n)?"
        if ((Read-Host -Prompt $msg).ToLower() -in @('', 'y')) {
            # update packages in existing environment
            & $mamba env update --file $ENV_FILE --prune
        } else {
            Write-Host 'Done!'
        }
    } else {
        Write-Host "`e[92mCreating `e[1;4m$envName`e[0;92m environment.`e[0m"
        # create environment
        & $mamba env create --file $ENV_FILE
    }
}

# *List packages
if ($ListPackages) {
    Invoke-Conda list
}

# *List environments
if ($ListEnv) {
    Invoke-Conda env list
}

# *Clean conda
if ($CondaClean) {
    & $mamba clean --all
}

# *Update conda
if ($CondaUpdate) {
    & $mamba update --name base --channel conda-forge --update-all
}

# *Remove environment
if ($RemoveEnv -and $envExists) {
    Invoke-Conda env remove --name $envName
}

# *Activate environment
if (-not $PSBoundParameters.Count -or $ActivateEnv -or $isActivEnv) {
    Enter-CondaEnvironment $envName
}
