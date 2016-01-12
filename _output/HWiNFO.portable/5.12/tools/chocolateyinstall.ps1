﻿$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Import-Module "$PSScriptRoot\Get-UrlFromFosshub.ps1"

$packageName = 'HWiNFO.portable'
$version = '5.12'
$version = $version.Replace(".","")
$url = Get-UrlFromFosshub "http://www.fosshub.com/genLink/HWiNFO/hw32_$version.zip"
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64 = Get-UrlFromFosshub "http://www.fosshub.com/genLink/HWiNFO/hw64_$version.zip"
$checksum = '7e07f58bc9be0196df32cb36453b8ae65a6f521d'
$checksumType = 'SHA1'
$checksum64 = '10b015239c827ed21f3a7bae8f193175c1206f46'
$checksumType64 = 'SHA1'

Install-ChocolateyZipPackage $packageName $url $toolsDir $url64 -checksum $checksum -checksumType $checksumType -checksum64 $checksum64 -checksumType64 $checksumType64
