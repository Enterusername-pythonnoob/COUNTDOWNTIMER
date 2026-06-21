# Countdown Timer

just a powershell countdown simple (3 files and read the README.md if u downloaded this, 
if u want to run this at powershell copy all the insides of countdown_color) 

A terminal countdown timer for PowerShell with big ASCII-art digits, a custom hex color picker, adjustable duration, and ASCII-boxed menus.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6)

## Features

- Big block-style ASCII digits, redrawn in place (no screen scrolling)
- Custom colors via ANSI true-color hex codes (`#FF00AA`, or pick from a 7-color rainbow menu)
- Adjustable countdown duration
- ASCII-boxed start and restart menus
- Stop early with `Space`, jump straight into a restart menu
- Works from Explorer, Command Prompt, or PowerShell via the included `.bat` launcher
- Quick Edit Mode auto-disabled on launch (prevents the classic console-freeze-on-click bug)

## Getting started

1. Download `countdown_color_psl.ps1` and `launcher.bat` into the same folder.
2. Run `launcher.bat`. That's it — works whether you double-click it, run it from `cmd`, or from a PowerShell prompt.

If Windows blocks the script, right-click the `.ps1` file -> Properties -> check "Unblock", then try again.

## Usage

**Start menu**

| Command | Action |
|---|---|
| `start` / `str` / `strt` / `s` | Begin the countdown |
| `time` | Set the countdown duration |
| `color` | Open the color picker |
| `c` / `clr` / `cr` | Clear the screen/logs |
| `q` / `quit` / `exit` | Quit |

**During the countdown**

| Key | Action |
|---|---|
| `Space` | Stop early, open restart menu |
| `Ctrl+C` | Force quit |

**Restart menu**

| Command | Action |
|---|---|
| `r` / `rld` / `rload` / `reload` / `restart` | Run again with the same settings |
| `c` / `clr` / `cr` | Clear logs |
| `q` / `quit` / `exit` | Quit |

## Color picker

Type `color` from the start menu to choose from a 7-color rainbow preset, or enter any custom hex code with `h`. Colors render using ANSI true-color escape codes rather than PowerShell's built-in named colors, since named colors can't represent arbitrary hex values. This needs a modern terminal (Windows Terminal or PowerShell 7+) to render correctly.

## License

MIT
