﻿$instDir    = "${ENV:TEMP}\nvidiainstall" # Folder to move desired components into
$ErrorActionPreference = 'Stop';
$packageArgs = @{
	packageName    = 'nvidia-display-driver'
	destination    = "${ENV:TEMP}\nvidiadriver" # Folder to extract drivers
	url64          = 'https://us.download.nvidia.com/Windows/430.64/430.64-desktop-win10-64bit-international-whql.exe'
	checksum64     = 'ebc8524e5668ce17ec510af6a40f045264743a33abc1c2bee67824dcf5a573c2'
	checksumType64 = 'sha256'
	silentArgs     = '-s -noreboot'
	validExitCodes = @(0,1)
	softwareName   = 'NVIDIA Graphics Driver*'
}

If ( [System.Environment]::OSVersion.Version.Major -ne '10' ) {
	$packageArgs['url64']      = 'https://us.download.nvidia.com/Windows/430.64/430.64-desktop-win8-win7-64bit-international-whql.exe'
	$packageArgs['checksum64'] = '414bd517b9e16c991497573dad3defa73e6e778416b94a0850fdf847ce330892'
}

If ( -not (Get-OSArchitectureWidth -compare 64) ) {
	Write-Warning "NVIDIA has ended support for 32bit operating systems."
	Write-Warning "32 bit users should specify version 391.35."
	Write-Warning "Security patches for 32bit may be available on geforce.com"
	Write-Error "32 bit no longer supported."
}

# Remove any previous tempfiles
Remove-Item "$instDir" -Recurse -Force -ea 0
New-Item -Path "$instDir" -ItemType Directory
New-Item -Path "$instDir\GFExperience" -ItemType Directory

# Download driver package as a zip
$packageArgs['file'] = "${ENV:TEMP}\nvidiadriver.zip"
Get-ChocolateyWebFile @packageArgs

# Unzip driver package
Get-ChocolateyUnzip @packageArgs

# Move everything we want to a new folder
Move-Item ($packageArgs['destination'] + "\Display.Driver"        ) -Destination "$instDir"
Move-Item ($packageArgs['destination'] + "\Display.Optimus"       ) -Destination "$instDir"
Move-Item ($packageArgs['destination'] + "\NVI2"                  ) -Destination "$instDir"
Move-Item ($packageArgs['destination'] + "\PhysX"                 ) -Destination "$instDir"
Move-Item ($packageArgs['destination'] + "\EULA.txt"              ) -Destination "$instDir"
Move-Item ($packageArgs['destination'] + "\license.txt"           ) -Destination "$instDir"
Move-Item ($packageArgs['destination'] + "\ListDevices.txt"       ) -Destination "$instDir"
Move-Item ($packageArgs['destination'] + "\setup.cfg"             ) -Destination "$instDir"
Move-Item ($packageArgs['destination'] + "\setup.exe"             ) -Destination "$instDir"
# Must include these legal files to satisfy the installer. GFE will not be installed.
Move-Item ($packageArgs['destination'] + "\GFExperience\PrivacyPolicy"      ) -Destination "$instDir\GFExperience"
Move-Item ($packageArgs['destination'] + "\GFExperience\EULA.html"          ) -Destination "$instDir\GFExperience"
Move-Item ($packageArgs['destination'] + "\GFExperience\FunctionalConsent_*") -Destination "$instDir\GFExperience"
$pp = Get-PackageParameters
if ( $pp.NV3DVision ) {
  Move-Item ($packageArgs['destination'] + "\NV3DVision"          ) -Destination "$instDir"
  Move-Item ($packageArgs['destination'] + "\NV3DVisionUSB.Driver") -Destination "$instDir"
}
if ( $pp.HDAudio ) {
  Move-Item ($packageArgs['destination'] + "\HDAudio"             ) -Destination "$instDir"
}

# Remove unused files
Remove-Item ($packageArgs['destination']) -Recurse -Force

# Finally, install
$packageArgs['file'    ] = "$instDir\setup.exe"
$packageArgs['fileType'] = 'EXE'
Install-ChocolateyInstallPackage @packageArgs
