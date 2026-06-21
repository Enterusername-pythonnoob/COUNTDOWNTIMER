# ---- Compatibility / Mouse-Freeze Fix ----
if ($psISE) {
    Write-Host ""
    Write-Host "This script is designed for the PowerShell console." -ForegroundColor Yellow
    Write-Host "Please run it in:" -ForegroundColor Yellow
    Write-Host " - Windows PowerShell" -ForegroundColor Cyan
    Write-Host " - Windows PowerShell (x86)" -ForegroundColor Cyan
    Write-Host " - Windows Terminal (using Windows PowerShell profile)" -ForegroundColor Cyan
    Write-Host ""
    Pause
    return
}
try {
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class ConsoleUtil
{
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetStdHandle(int nStdHandle);
    [DllImport("kernel32.dll")]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
    [DllImport("kernel32.dll")]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
}
"@
$STD_INPUT_HANDLE = -10
$ENABLE_QUICK_EDIT = 0x40
$hConsole = [ConsoleUtil]::GetStdHandle($STD_INPUT_HANDLE)
$mode = 0
if ([ConsoleUtil]::GetConsoleMode($hConsole, [ref]$mode)) {
    $newMode = $mode -band (-bnot $ENABLE_QUICK_EDIT)
    [ConsoleUtil]::SetConsoleMode($hConsole, $newMode) | Out-Null
}
} catch {}
# ------------------------------------------

# BUGFIX: -ForegroundColor only accepts the 16 named console colors and
# CANNOT represent a hex code like #FF0000. To support arbitrary hex colors
# (and a full rainbow picker) we switch to ANSI 24-bit true-color escape
# codes instead, which Windows Terminal / modern PS consoles understand.

$ESC = [char]27

function Get-AnsiColor {
    param([string]$Hex)
    $h = $Hex -replace '^#', ''
    if ($h.Length -ne 6) { $h = "00FF00" }
    $r = [Convert]::ToInt32($h.Substring(0,2),16)
    $g = [Convert]::ToInt32($h.Substring(2,2),16)
    $b = [Convert]::ToInt32($h.Substring(4,2),16)
    return "$ESC[38;2;$r;$g;${b}m"
}

function Write-Themed {
    param([string]$Text, [string]$Hex, [switch]$NoNewline)
    $code = Get-AnsiColor $Hex
    $reset = "$ESC[0m"
    if ($NoNewline) { Write-Host "$code$Text$reset" -NoNewline }
    else { Write-Host "$code$Text$reset" }
}

$themeHex = "00FF00"   # default green
$autoStart = $false
$duration = 100

$digitArt = @{
'0' = @(" ### ", "#   #", "#   #", "#   #", " ### ")
'1' = @("  #  ", " ##  ", "  #  ", "  #  ", " ### ")
'2' = @(" ### ", "#   #", "   # ", "  #  ", "#####")
'3' = @(" ### ", "#   #", "  ## ", "#   #", " ### ")
'4' = @("#   #", "#   #", "#####", "    #", "    #")
'5' = @("#####", "#    ", "#### ", "    #", "#### ")
'6' = @(" ### ", "#    ", "#### ", "#   #", " ### ")
'7' = @("#####", "    #", "   # ", "  #  ", "  #  ")
'8' = @(" ### ", "#   #", " ### ", "#   #", " ### ")
'9' = @(" ### ", "#   #", " ####", "    #", " ### ")
}

function Show-BigNumber {
    param([string]$numStr, [int]$top, [string]$Hex)
    $code = Get-AnsiColor $Hex
    $reset = "$ESC[0m"
    for ($row = 0; $row -lt 5; $row++) {
        $line = ($numStr.ToCharArray() | ForEach-Object {
            $digitArt[[string]$_][$row]
        }) -join "  "
        [Console]::SetCursorPosition(0, $top + $row)
        Write-Host ($code + $line.PadRight(60) + $reset) -NoNewline
    }
}

function Show-Box {
    param([string]$Title, [string[]]$Lines, [string]$Hex)
    $width = ($Lines + $Title) | ForEach-Object { $_.Length } | Sort-Object -Descending | Select-Object -First 1
    $width = $width + 4
    $top = "+" + ("-" * ($width - 2)) + "+"
    $titlePad = $width - 2 - $Title.Length
    $leftPad = [Math]::Floor($titlePad / 2)
    $rightPad = $titlePad - $leftPad
    $titleLine = "|" + (" " * $leftPad) + $Title + (" " * $rightPad) + "|"
    Write-Host ""
    Write-Themed -Hex $Hex -Text $top
    Write-Themed -Hex $Hex -Text $titleLine
    Write-Themed -Hex $Hex -Text $top
    foreach ($line in $Lines) {
        $pad = $width - 3 - $line.Length
        Write-Themed -Hex $Hex -Text ("| " + $line + (" " * $pad) + "|")
    }
    Write-Themed -Hex $Hex -Text $top
    Write-Host ""
}

# ---- Rainbow color picker menu ----
function Show-ColorMenu {
    $rainbow = @(
        @{ Name = "Red";    Hex = "FF0000" },
        @{ Name = "Orange"; Hex = "FF7F00" },
        @{ Name = "Yellow"; Hex = "FFFF00" },
        @{ Name = "Green";  Hex = "00FF00" },
        @{ Name = "Blue";   Hex = "0000FF" },
        @{ Name = "Indigo"; Hex = "4B0082" },
        @{ Name = "Violet"; Hex = "8B00FF" }
    )

    $lines = @()
    for ($i = 0; $i -lt $rainbow.Count; $i++) {
        $lines += ("{0}) {1,-8} #{2}" -f ($i + 1), $rainbow[$i].Name, $rainbow[$i].Hex)
    }
    $lines += "h) Custom hex (e.g. #FF00AA)"
    $lines += "b) Back to menu"

    Show-Box -Title "PICK A COLOR" -Hex $themeHex -Lines $lines

    # Print live swatches so each option shows its own real color
    foreach ($c in $rainbow) {
        Write-Themed -Hex $c.Hex -Text ("  " + ("#" * 10) + "  " + $c.Name)
    }
    Write-Host ""

    do {
        $choice = Read-Host "Pick a number, 'h' for hex, or 'b' to go back"
    } while ($choice -notmatch '^(1|2|3|4|5|6|7|h|b)$')

    if ($choice -eq 'b') { return }

    if ($choice -eq 'h') {
        do {
            $hexInput = Read-Host "Enter hex color (e.g. #FF00AA)"
        } while ($hexInput -notmatch '^#?[0-9A-Fa-f]{6}$')
        $script:themeHex = ($hexInput -replace '^#', '').ToUpper()
        Write-Themed -Hex $script:themeHex -Text "Theme set to #$($script:themeHex)"
    }
    else {
        $idx = [int]$choice - 1
        $script:themeHex = $rainbow[$idx].Hex
        Write-Themed -Hex $script:themeHex -Text "Theme set to $($rainbow[$idx].Name) (#$($rainbow[$idx].Hex))"
    }
    Start-Sleep -Seconds 1
}

# ---- Duration picker menu ----
function Show-DurationMenu {
    Show-Box -Title "SET DURATION" -Hex $themeHex -Lines @(
        "Current duration: $duration secs",
        "Type a number of seconds to count down from",
        "b) Back to menu"
    )
    do {
        $choice = Read-Host "New duration (or 'b' to go back)"
    } while ($choice -notmatch '^(b|\d+)$')

    if ($choice -ne 'b') {
        $script:duration = [int]$choice
        Write-Themed -Hex $themeHex -Text "Duration set to $script:duration secs"
        Start-Sleep -Seconds 1
    }
}

try {
while ($true) {

    # ---- START MENU ----
    if (-not $autoStart) {
        Show-Box -Title "START MENU" -Hex $themeHex -Lines @(
            "start | str | strt | s -> begin countdown",
            "time                    -> set duration ($duration secs)",
            "color                   -> change countdown color",
            "c | clr | cr            -> wipe command logs",
            "q | quit | exit         -> quit"
        )
        do {
            $action = Read-Host "Your choice"
        } while ($action -notmatch '^(start|str|strt|s|c|clr|cr|q|quit|exit|time|color)$')
    }

    if ($action -match '^(q|quit|exit)$') { break }

    if ($action -match '^(c|clr|cr)$') {
        Clear-Host
        $autoStart = $false
        Write-Host "Command logs wiped. Back to normal." -ForegroundColor White
        continue
    }

    if ($action -eq 'time') {
        Clear-Host
        Show-DurationMenu
        Clear-Host
        $autoStart = $false
        continue
    }

    if ($action -eq 'color') {
        Clear-Host
        Show-ColorMenu
        Clear-Host
        $autoStart = $false
        continue
    }

    Clear-Host
    $autoStart = $false

    # ---- COUNTDOWN ----
    Write-Themed -Hex $themeHex -Text "`nCountdown running...`nPress [Space] -> restart menu`n"

    $topRow = [Console]::CursorTop + 1
    $gotoRestart = $false
    [Console]::CursorVisible = $false

    for ($i = $duration; $i -ge 0; $i--) {

        $padWidth = if ($duration -ge 100) { 3 } else { 2 }
        Show-BigNumber -numStr ("{0:D$padWidth}" -f $i) -top $topRow -Hex $themeHex

        $elapsed = 0
        while ($elapsed -lt 1000) {
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if ($key.Key -eq 'Spacebar') {
                    [Console]::SetCursorPosition(0, $topRow + 6)
                    Write-Host "-> Opening restart menu..." -ForegroundColor Cyan
                    $gotoRestart = $true
                    break
                }
            }
            Start-Sleep -Milliseconds 100
            $elapsed += 100
        }
        if ($gotoRestart) { break }
    }

    # Flush ghost inputs
    while ([Console]::KeyAvailable) { [Console]::ReadKey($true) | Out-Null }
    [Console]::CursorVisible = $true

    if (-not $gotoRestart) {
        [Console]::SetCursorPosition(0, $topRow + 6)
        Write-Themed -Hex $themeHex -Text "Countdown finished!"
    }

    # ---- RESTART MENU ----
    Show-Box -Title "RESTART MENU" -Hex $themeHex -Lines @(
        "r | rld | rload | reload | restart -> reload timer ($duration secs)",
        "time                                -> set duration",
        "color                               -> change countdown color",
        "c | clr | cr                        -> wipe command logs",
        "q | quit | exit                     -> quit"
    )

    do {
        $action = Read-Host "Your choice"
    } while ($action -notmatch '^(r|rld|rload|reload|restart|c|clr|cr|q|quit|exit|time|color)$')

    if ($action -match '^(q|quit|exit)$') { break }

    if ($action -match '^(c|clr|cr)$') {
        Clear-Host
        $autoStart = $false
        Write-Host "Command logs wiped. Back to normal." -ForegroundColor White
        continue
    }

    if ($action -eq 'time') {
        Clear-Host
        Show-DurationMenu
        Clear-Host
        $autoStart = $false
        continue
    }

    if ($action -eq 'color') {
        Clear-Host
        Show-ColorMenu
        Clear-Host
        $autoStart = $false
        continue
    }

    $autoStart = $true
    Clear-Host
}
}
finally {
    [Console]::CursorVisible = $true
}