# Big Number Countdown Timer

A PowerShell countdown timer with large ASCII-art digits, a custom hex
color picker, adjustable duration, and ASCII-boxed menus.

## Files

- `countdown_color_psl.ps1` — the actual script. This does all the work.
- `countdown.bat` — a launcher. Lets you double-click to run, or run from
  Command Prompt or PowerShell without worrying about execution policy.

Keep both files in the same folder. The `.bat` looks for the `.ps1` by
its exact filename, so if you rename one, update the other to match.

## How to run it

Double-click `countdown.bat`. That's it.

It also works if you run it from Command Prompt or from a PowerShell
window — same file, any of the three.

If Windows still refuses to run it (rare), right-click the `.ps1` file
-> Properties -> check "Unblock" near the bottom, then try again.

## Controls

**Start menu**
- `start` / `str` / `strt` / `s` — begin the countdown
- `time` — set how many seconds to count down from
- `color` — open the color picker
- `c` / `clr` / `cr` — clear the screen/logs
- `q` / `quit` / `exit` — quit

**During the countdown**
- `Space` — stop early and open the restart menu
- `Ctrl+C` — force quit (cursor visibility is restored automatically)

**Restart menu** (shown after countdown ends or is stopped)
- `r` / `rld` / `rload` / `reload` / `restart` — run it again, same
  duration and color as last time
- `c` / `clr` / `cr` — clear logs
- `q` / `quit` / `exit` — quit

## Color picker

Type `color` from the start menu to choose from a 7-color rainbow
preset, or pick `h` to enter any custom hex code (e.g. `#FF00AA`).

Colors use ANSI true-color escape codes, not the built-in PowerShell
`-ForegroundColor` names — this is what makes arbitrary hex values
possible. Needs a modern terminal (Windows Terminal or PowerShell 7+
console) to display correctly; very old `conhost` windows may not
render true color properly.

## Duration

Type `time` from the start menu, then type any number of seconds.
The countdown will start from that number next time you run it, and
the setting persists across restarts within the same session.

## Notes

- Quick Edit Mode is disabled automatically on startup, which prevents
  the classic "console freezes when you click inside it" issue.
- Running the `.ps1` directly inside the PowerShell ISE is blocked —
  ISE's output pane doesn't support the cursor positioning this script
  relies on. Use a real PowerShell console, Command Prompt (via the
  `.bat`), or Windows Terminal instead.