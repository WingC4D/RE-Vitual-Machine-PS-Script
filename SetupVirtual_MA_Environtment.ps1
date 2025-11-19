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
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
<#
Installing Tooling From Shared Folder, Variables To Edit Are Above
#>
function Install-RevresingTools {
    $ida_home = Join-Path $env:ProgramFiles -ChildPath "IDA Home (PC) 9.2"
    $binary_ninja = Join-Path -Path $env:APPDATA -ChildPath "binaryninja"
    if (-not (Test-Path -Path $ida_home) -and -not (Test-Path -Path $binary_ninja)) {
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
        Remove-Item $ida_local_path
        Write-Host "[i] Finshed Deleting The IDA Installer"
        Write-Host "[i] Now Running The Binary Ninja Installer...\n[i] Expect A Pop-Up Window!" -ForegroundColor  Yellow
        Start-Process -FilePath $binaryninja_local_path -Verb RunAs -Wait
        Write-Host "[+] Finished Installing Binary Ninja!\n[i] Deleting The Binary Ninja Installer..." -ForegroundColor Green
        Remove-Item $binaryninja_local_path
        Write-Host "[i] Finshed Deleting The Binary Ninja Installer!" -ForegroundColor Green
        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
    return 
}

function Update-Winget {
    winget update --all --include-unknown
    winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
function Install-WingetTools {
    if (-not (Test-Path -Path $tools_path)){
        New-Item -Path $tools_path -ItemType Directory
    }
    Update-Winget
    $winget_resources_list = @(
        "Brave.Brave", "Google.Chrome", "WireShark", "ILSpy",
        "Microsoft.VisualStudio.2022.Community", "Microsoft.VisualStudioCode", "Microsoft.WinDbg", "Microsoft.PowerToys",
        "Microsoft.PowerShell", "Microsoft.SysInternalsSuite","Git.Git", "x64dbg", "Notepad++.Notepad++",
        "Obsidian.Obsidian", "JetBrains.CLion", "JetBrains.PyCharm.Community", "Python3.13",
        "Cmake", "CygWin.CygWin", "PE-Bear", "Detect-It-Easy"
    )
    Set-Location $tools_path
    foreach ($resource in $winget_resources_list) {
        $curr_str = "[!] Running Winget To Find: " + $resource + "..."
        Write-Host $curr_str -ForegroundColor Cyan
        $installation_path = Join-Path -Path $tools_path -ChildPath $resource
        if (-not (Test-Path $resource)) {
            New-Item -Path $installation_path -ItemType Directory
        }
        if ($resource -eq "Git.Git") {
            winget install $resource -s winget --location $installation_path --silent --accept-package-agreements --accept-source-agreements --id Git.Git
        } 
        elseif (-not (($resource -eq "Brave.Brave") -or ($resource -eq "Google.Chrome"))){            
            winget install $resource -s winget --location $installation_path --silent --accept-package-agreements --accept-source-agreements
        } else {
            winget install $resource -s winget --silent --accept-package-agreements --accept-source-agreements
        }
    }
    $x64dbg_path = Join-Path -Path $tools_path -ChildPath "x64dbg\release\x96dbg.exe"
    [System.Environment]::SetEnvironmentVariable("x64", $x64dbg_path , "User")
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
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
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
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
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
function Install-IdaThemes {

}
function Install-x64Themes {
    $x64dbg_themes_list = @(
        “https://gist.github.com/ThunderCls/4dcc4b8c1cace8c9cae5612fc696d465/archive/59c9bfdc208bc444f189f55b6758cfb3ad97df5a.zip”,
        "https://gist.github.com/stonedreamforest/3907d3b3081df8e73c8c4e2ce9d1f9c2/archive/69fc0725059a9c846a81143fc2d18dce54d0979e.zip”,
        “https://gist.github.com/ThunderCls/6fffbe7f3e2edd697b36a2decab80b64/archive/d2695424ba70771f27a16fd34239d4867460d3e5.zip”
    )
    Set-Location C:\Tools\x64dbg\release\themes
    foreach ($link in $x64dbg_themes_list) {
       Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.WebClient]::new().DownloadString('https://community.chocolatey.org/install.ps1') | Invoke-Expression
    }

}
$terminal_themes = @(
	“https://github.com/catppuccin/windows-terminal.git”
)



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
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
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