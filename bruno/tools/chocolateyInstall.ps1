$ErrorActionPreference = 'Stop'

# Define the tools path (directory where the script resides)
$toolsPath = Split-Path $MyInvocation.MyCommand.Definition

# Find the installer file
$installerFile = Get-ChildItem "$toolsPath\*.exe" | Select-Object -First 1
if (!$installerFile) {
    throw "No installer file (.exe) found in the tools directory."
}

# Define package arguments
$packageArgs = @{
    packageName    = $Env:ChocolateyPackageName
    fileType       = 'exe' # Assuming the installer is an .exe
    file64         = $installerFile.FullName
    silentArgs     = '/S'
    validExitCodes = @(0)
    softwareName   = 'bruno'
}

# Install the package
Install-ChocolateyInstallPackage @packageArgs

# Clean up installer files
$installerFile | Remove-Item -Force -ErrorAction SilentlyContinue
if (Test-Path $installerFile.FullName) {
    Set-Content "$($installerFile.FullName).ignore" ""
}

# Verify the installation
$packageName = $packageArgs.packageName
$installLocation = Get-AppInstallLocation "$packageName*"
if (!$installLocation) {
    Write-Warning "Can't find $packageName install location"
    return
}
Write-Host "$packageName installed to '$installLocation'"

# Register the application (assuming the executable matches the package name)
$exePath = Join-Path $installLocation "$packageName.exe"
if (-Not (Test-Path $exePath)) {
    Write-Warning "Executable not found at '$exePath'"
    return
}

Register-Application $exePath
Write-Host "$packageName registered as $packageName"
