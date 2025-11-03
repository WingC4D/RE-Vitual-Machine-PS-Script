<#
Run This Environment Set-Up Script As A Local ADMIN OR IT WILL FAIL!
#>
Clear-Host
<#
Golbal Variables
#>
$ida_local_path          = Join-Path -Path $HOME -ChildPath "Desktop\install_ida.exe"
$binaryninja_local_path  = Join-Path -Path $HOME -ChildPath "Desktop\install_binja.exe"
$tools_path              = Join-Path -Path $env:SystemDrive -ChildPath "Tools"
$fonts_path              = Join-Path -Path $env:SystemDrive -ChildPath "Fonts"
$ida_global_path         = "Z:\Tools Installers\install_ida_92.exe"
$binaryninja_global_path = "Z:\Tools Installers\install_binja.exe" 

<#
Function Defintions 
Installing Choco -  A Better Maintained Winget
#>
function Install-Choco {
    Set-Location  $env:ProgramData
    Write-Host "[i] Downloading & Installing Chocho..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.WebClient]::new().DownloadString('https://community.chocolatey.org/install.ps1') | Invoke-Expression
    Write-Host "[+] Finished Installing Choco!" -ForegroundColor Green
    choco refreshenv
}
<#
Installing Tooling From Shared Folder, Variables To Edit Are Above
#>
function Install-RevresingTools {
    Copy-Item $ida_global_path $ida_local_path 
    if (-not (Test-Path -Path $ida_local_path)) {
        Write-Host "[X] Failed To Copy The IDA Installer!" -ForegroundColor Red        
        Write-Host '[i] Please Make Sure Your "$ida_local_path" Variable Is Set-Up Correctly!' -ForegroundColor Magenta   
        return
    }
    Write-Host "[i] Copied The Ida Installer To: " + $ida_local_path + "!"
    Copy-Item $binaryninja_global_path $binaryninja_local_path
    if (-not (Test-Path -Path $binaryninja_local_path)) {
        Write-Host "[X] Failed To Copy The Binary Ninja Installer!" -ForegroundColor Red
        Write-Host "[i] Please Make Sure Your `$binaryninja_local_path` Variable Is Set-Up Correctly!" -ForegroundColor Magenta   
        return
    }
    $binja_str = "[i] Copied The Binary Ninja Installer To: " + $binaryninja_local_path + "!\n[i] Now Running The IDA Installer...\n[i] Expect A Pop-Up Window!"
    Write-Host $binja_str  -ForegroundColor  Yellow
    Start-Process -FilePath $ida_local_path -Verb RunAs -Wait
    Write-Host "[+] Finished Installing IDA Home (PC) 9.2!"
    Write-Host "[i] Now Deleting The IDA Installer..." 
    Remove-Item
    Write-Host "[i] Finshed Deleting The IDA Installer"
    Write-Host "[i] Now Running The Binary Ninja Installer...\n[i] Expect A Pop-Up Window!" -ForegroundColor  Yellow
    Start-Process -FilePath $binaryninja_local_path -Verb RunAs -Wait
    Write-Host "[+] Finished Installing Binary Ninja!\n[i] Deleting The Binary Ninja Installer..."
    Remove-Item
    Write-Host
    choco refreshenv
    return 
}

function Update-Winget {
    winget update --all --include-unknown
    winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
    choco refreshenv
}
function Install-WingetTools {
    if (-not (Test-Path -Path $tools_path)){
        New-Item -Path $tools_path -ItemType Directory
    }
    Update-Winget
    $winget_resources_list = @(
        "Brave.Brave", "Google.Chrome", "WireShark.WireShark", "ILSpy",
        "Microsoft.VisualStudio.2022.Community", "Microsoft.VisualStudioCode", "Microsoft.WinDbg", "Microsoft.PowerToys",
        "Microsoft.PowerShell","Git.Git", "x64dbg", "Notepad++.Notepad++", "Obsidian.Obsidian",
        "JetBrains.CLion", "JetBrains.PyCharm.Community", "Python3.13", "Cmake",
        "CygWin.CygWin", "SysInternals Suite", "PE-Bear", "Detect-It-Easy"
    )
    foreach ($resource in $winget_resources_list) {
        $curr_str = "[!] Running Winget To Find: " + $resource + "..."
        Write-Host $curr_str -ForegroundColor Cyan
        if ($resource -eq "Git.Git") {
            winget install $resource -s winget --location $tools_path --silent --accept-package-agreements --accept-source-agreements --id Git.Git
        } elseif (-not (($resource -eq "Brave.Brave") -or ($resource -eq "Google.Chrome"))){            
            winget install $resource -s winget --location $tools_path --silent --accept-package-agreements --accept-source-agreements
        } else {
            winget install $resource -s winget --silent --accept-package-agreements --accept-source-agreements
        }
    }
    choco refreshenv
}
function Install-ChocoTools {
    Set-Location $tools_path
    $choco_tools_list = @(
        "reclass.net",
        "010editor",
        "malcat"
    )
    foreach ($tool in $choco_tools_list) {
        choco install $tool -y 
    }
}
function Install-GitHubTools {
    if (-not (Test-Path -Path $tools_path)){
        New-Item -Path $tools_path -ItemType Directory
    }
    Set-Location $tools_path
    $git_links_list = @(
        "https://github.com/HexRaysSA/ida-sdk.git",
        "https://github.com/x64dbg/ScyllaHide.git",
        "https://github.com/binsync/binsync.git",
        "https://github.com/Vector35/binaryninja-api.git"
    )

    foreach ($link in $git_links_list) {
        git clone $link --recursive
    }
    choco refreshenv
}

function Install-ChocoFonts {
    if (-not (Test-Path -Path $fonts_path)){
        New-Item -Path $fonts_path -ItemType "Directory"
    } 
    Set-Location $fonts_path
    $font_names_list = @(
        "nerd-fonts-firacode",
        "nerd-fonts-jetbrainsmono",
        "nerd-fonts-Monaspace",
        "nerd-fonts-martianmono",
        "nerd-fonts-mononoki"
    )
    foreach ($font in $font_names_list) {
        choco install $font -y 
    } 
    choco refreshenv
}
function Install-All {
    Install-Choco
    Install-RevresingTools
    Install-ChocoTools
    Install-ChocoFonts
    Install-WingetTools
    Install-GitHubTools
} 

Install-All