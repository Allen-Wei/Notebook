# How to pass a switch parameter to another PowerShell script?(如何将用户输入的参数传递到另一个PowerShell的脚本调用中)

## Question
I have two PowerShell scripts, which have switch parameters:

__compile-tool1.ps1:__

```powershell
[CmdletBinding()]
param(
  [switch]$VHDL2008
)

Write-Host "VHDL-2008 is enabled: $VHDL2008"
```

__compile.ps1:__
```powershell
[CmdletBinding()]
param(
  [switch]$VHDL2008
)

if (-not $VHDL2008)
{ compile-tool1.ps1            }
else
{ compile-tool1.ps1 -VHDL2008  }
```

How can I pass a switch parameter to another PowerShell script, without writing big if..then..else or case statements?

I don't want to convert the parameter $VHDL2008 of compile-tool1.ps1 to type bool, because, both scripts are front-end scripts (used by users). The latter one is a high-level wrapper for multiple compile-tool*.ps1 scripts.

## Anwser
You can specify `$true` or `$false` on a switch:
```powershell
compile-tool1.ps1 -VHDL2008:$true
compile-tool1.ps1 -VHDL2008:$false
```
So just pass the actual value:
```powershell
compile-tool1.ps1 -VHDL2008:$VHDL2008
```

## Other Sample

```posershell
param (
    [switch]$NoRelease,
    [switch]$Verbose,
    [string[]]$Directories,
    [string]$siteDir = "D:/Temporary/copy"
)

if($NoRelease){
	Write-Host "NoRelease"
}else{
	Write-Host "Release solution ..."
	msbuild ../AutoMis.Website.sln /t:Build /p:Configuration=Release
}

$siteLocation = $siteDir;

if($Directories.Length -gt 0){
	Write-Host "Custome copy ..."
	foreach($dir in $Directories){
		Write-Host "Copy $dir to $siteLocation/$dir ..."
	 	Copy-Item -Path $dir -Destination $siteLocation -Recurse -Force -Verbose:$Verbose
	}
	Write-Host "Custome copy end."
	return;
}
```