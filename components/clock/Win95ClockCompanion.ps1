param(
    [string]$ConfigPath,
    [switch]$SelfTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not ("Win95Clock.Native" -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace Win95Clock
{
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
    public struct POINT { public int X; public int Y; }

    public static class Native
    {
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        public static extern bool GetCursorPos(out POINT lpPoint);

        [DllImport("user32.dll")]
        public static extern bool IsWindowVisible(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

        [DllImport("user32.dll")]
        public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

        public static IntPtr FindTaskbarWindowForProcess(int pid)
        {
            IntPtr best = IntPtr.Zero;
            double bestScore = 0;

            EnumWindows(delegate(IntPtr hWnd, IntPtr lParam)
            {
                if (!IsWindowVisible(hWnd)) return true;

                uint windowPid;
                GetWindowThreadProcessId(hWnd, out windowPid);
                if (windowPid != pid) return true;

                RECT r;
                if (!GetWindowRect(hWnd, out r)) return true;

                int width = Math.Max(0, r.Right - r.Left);
                int height = Math.Max(0, r.Bottom - r.Top);
                if (width < 40 || height < 20) return true;

                int min = Math.Min(width, height);
                int max = Math.Max(width, height);
                if (min <= 0 || min > 400) return true;

                double score = (double)max / min;
                if (score > bestScore)
                {
                    bestScore = score;
                    best = hWnd;
                }
                return true;
            }, IntPtr.Zero);

            return best;
        }
    }
}
"@
}

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ConfigPath) { $ConfigPath = Join-Path $baseDir "clock-config.json" }

$config = [ordered]@{
    Mode = "Enhanced"
    HoverDelayMs = 500
    CloseDelayMs = 350
    ClockHitPixels = 76
}

if (Test-Path $ConfigPath) {
    $loaded = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    foreach ($name in @("Mode","HoverDelayMs","CloseDelayMs","ClockHitPixels")) {
        if ($loaded.PSObject.Properties.Name -contains $name) { $config[$name] = $loaded.$name }
    }
}

if ($config.Mode -notin @("Authentic","Enhanced")) {
    throw "Clock companion Mode must be Authentic or Enhanced."
}

if ($SelfTest) {
    Write-Host "Win95 Clock Companion self-test"
    Write-Host ("Mode: {0}" -f $config.Mode)
    Write-Host ("HoverDelayMs: {0}" -f $config.HoverDelayMs)
    Write-Host "PASS"
    exit 0
}

$pidFile = Join-Path $baseDir "companion.pid"
Set-Content -Path $pidFile -Value $PID -Encoding ASCII
Register-EngineEvent PowerShell.Exiting -Action {
    Remove-Item $using:pidFile -Force -ErrorAction SilentlyContinue
} | Out-Null

$classicGray = [System.Drawing.Color]::FromArgb(192,192,192)
$classicNavy = [System.Drawing.Color]::FromArgb(0,0,128)
$classicWhite = [System.Drawing.Color]::White
$classicBlack = [System.Drawing.Color]::Black
$classicGrayText = [System.Drawing.Color]::FromArgb(128,128,128)
$classicInfo = [System.Drawing.Color]::FromArgb(255,255,225)
$classicFont = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,[System.Drawing.FontStyle]::Regular)

function Get-RetroBarTaskbarRect {
    $processes = Get-Process -Name "RetroBar" -ErrorAction SilentlyContinue
    foreach ($process in $processes) {
        $handle = $process.MainWindowHandle
        if ($handle -eq [IntPtr]::Zero) {
            $handle = [Win95Clock.Native]::FindTaskbarWindowForProcess($process.Id)
        }

        if ($handle -ne [IntPtr]::Zero) {
            $rect = New-Object Win95Clock.RECT
            if ([Win95Clock.Native]::GetWindowRect($handle,[ref]$rect)) {
                $width = $rect.Right - $rect.Left
                $height = $rect.Bottom - $rect.Top
                if ($width -gt 40 -and $height -gt 20) {
                    return [pscustomobject]@{
                        Left=$rect.Left; Top=$rect.Top; Right=$rect.Right; Bottom=$rect.Bottom
                        Width=$width; Height=$height; Handle=$handle
                    }
                }
            }
        }
    }
    return $null
}

function Get-RetroBarEdge {
    $settings = Join-Path $env:LOCALAPPDATA "RetroBar\settings.json"
    if (Test-Path $settings) {
        try {
            $json = Get-Content $settings -Raw | ConvertFrom-Json
            if ($json.PSObject.Properties.Name -contains "Edge") {
                switch ("$($json.Edge)") {
                    "0" { return "Left" }
                    "1" { return "Top" }
                    "2" { return "Right" }
                    "3" { return "Bottom" }
                    "Left" { return "Left" }
                    "Top" { return "Top" }
                    "Right" { return "Right" }
                    "Bottom" { return "Bottom" }
                }
            }
        } catch {}
    }
    return "Bottom"
}

function Get-ClockHitRect {
    param($TaskRect,[string]$Edge)
    $span = [Math]::Max(52,[int]$config.ClockHitPixels)

    if ($Edge -in @("Top","Bottom")) {
        return [System.Drawing.Rectangle]::FromLTRB(
            [Math]::Max($TaskRect.Left,$TaskRect.Right-$span),
            $TaskRect.Top,$TaskRect.Right,$TaskRect.Bottom
        )
    }

    return [System.Drawing.Rectangle]::FromLTRB(
        $TaskRect.Left,
        [Math]::Max($TaskRect.Top,$TaskRect.Bottom-$span),
        $TaskRect.Right,$TaskRect.Bottom
    )
}

function Get-CursorPoint {
    $p = New-Object Win95Clock.POINT
    [void][Win95Clock.Native]::GetCursorPos([ref]$p)
    return [System.Drawing.Point]::new($p.X,$p.Y)
}

function Set-ClassicButton {
    param([System.Windows.Forms.Button]$Button)
    $Button.Font = $classicFont
    $Button.BackColor = $classicGray
    $Button.ForeColor = $classicBlack
    $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
    $Button.UseVisualStyleBackColor = $false
}

function Render-ClassicCalendar {
    param([System.Windows.Forms.Panel]$Panel)

    $state = $Panel.Tag
    $year = [int]$state.Year
    $month = [int]$state.Month
    $selected = [datetime]$state.Selected
    $culture = [System.Globalization.CultureInfo]::CurrentCulture

    $state.Header.Text = ([datetime]::new($year,$month,1)).ToString("MMMM yyyy",$culture)

    $first = [datetime]::new($year,$month,1)
    $firstDay = [int]$culture.DateTimeFormat.FirstDayOfWeek
    $offset = (([int]$first.DayOfWeek - $firstDay) + 7) % 7
    $start = $first.AddDays(-$offset)

    for ($i=0; $i -lt 42; $i++) {
        $date = $start.AddDays($i)
        $label = $state.DayLabels[$i]
        $label.Text = $date.Day.ToString()
        $label.Tag = $date
        $label.ForeColor = $(if ($date.Month -eq $month) { $classicBlack } else { $classicGrayText })
        $label.BackColor = $classicGray

        if ($date.Date -eq $selected.Date) {
            $label.BackColor = $classicNavy
            $label.ForeColor = $classicWhite
        }
    }

    $state.Footer.Text = $selected.ToLongDateString()
}

function New-ClassicCalendarPanel {
    param([datetime]$Date = (Get-Date))

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size = New-Object System.Drawing.Size(244,214)
    $panel.BackColor = $classicGray

    $prev = New-Object System.Windows.Forms.Button
    $prev.Text = "<"
    $prev.Location = New-Object System.Drawing.Point(4,4)
    $prev.Size = New-Object System.Drawing.Size(26,23)
    Set-ClassicButton $prev

    $next = New-Object System.Windows.Forms.Button
    $next.Text = ">"
    $next.Location = New-Object System.Drawing.Point(214,4)
    $next.Size = New-Object System.Drawing.Size(26,23)
    Set-ClassicButton $next

    $header = New-Object System.Windows.Forms.Label
    $header.Location = New-Object System.Drawing.Point(34,5)
    $header.Size = New-Object System.Drawing.Size(176,21)
    $header.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $header.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,[System.Drawing.FontStyle]::Bold)
    $header.BackColor = $classicNavy
    $header.ForeColor = $classicWhite

    $grid = New-Object System.Windows.Forms.TableLayoutPanel
    $grid.Location = New-Object System.Drawing.Point(4,31)
    $grid.Size = New-Object System.Drawing.Size(236,151)
    $grid.ColumnCount = 7
    $grid.RowCount = 7
    $grid.BackColor = $classicGray
    $grid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::None

    for ($c=0; $c -lt 7; $c++) {
        [void]$grid.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,14.2857)))
    }
    for ($r=0; $r -lt 7; $r++) {
        [void]$grid.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent,14.2857)))
    }

    $culture = [System.Globalization.CultureInfo]::CurrentCulture
    $firstDay = [int]$culture.DateTimeFormat.FirstDayOfWeek
    for ($c=0; $c -lt 7; $c++) {
        $dow = ($firstDay + $c) % 7
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Dock = [System.Windows.Forms.DockStyle]::Fill
        $lbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $lbl.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,[System.Drawing.FontStyle]::Bold)
        $lbl.Text = $culture.DateTimeFormat.AbbreviatedDayNames[$dow]
        $lbl.ForeColor = $classicBlack
        $grid.Controls.Add($lbl,$c,0)
    }

    $dayLabels = New-Object System.Collections.ArrayList
    for ($i=0; $i -lt 42; $i++) {
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Dock = [System.Windows.Forms.DockStyle]::Fill
        $lbl.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $lbl.Font = $classicFont
        $lbl.Cursor = [System.Windows.Forms.Cursors]::Hand
        $lbl.Margin = New-Object System.Windows.Forms.Padding(1)
        $lbl.Add_Click({
            $calendarPanel = $this.Parent.Parent
            $calendarPanel.Tag.Selected = [datetime]$this.Tag
            Render-ClassicCalendar $calendarPanel
        })
        [void]$dayLabels.Add($lbl)
        $grid.Controls.Add($lbl,($i % 7),([Math]::Floor($i / 7)+1))
    }

    $footer = New-Object System.Windows.Forms.Label
    $footer.Location = New-Object System.Drawing.Point(4,185)
    $footer.Size = New-Object System.Drawing.Size(236,24)
    $footer.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $footer.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $footer.Font = $classicFont
    $footer.BackColor = $classicGray
    $footer.ForeColor = $classicBlack

    $panel.Controls.AddRange(@($prev,$next,$header,$grid,$footer))
    $panel.Tag = [pscustomobject]@{
        Year=$Date.Year; Month=$Date.Month; Selected=$Date.Date
        Header=$header; Footer=$footer; DayLabels=$dayLabels
    }

    $prev.Add_Click({
        $m = [datetime]::new($panel.Tag.Year,$panel.Tag.Month,1).AddMonths(-1)
        $panel.Tag.Year = $m.Year
        $panel.Tag.Month = $m.Month
        Render-ClassicCalendar $panel
    })

    $next.Add_Click({
        $m = [datetime]::new($panel.Tag.Year,$panel.Tag.Month,1).AddMonths(1)
        $panel.Tag.Year = $m.Year
        $panel.Tag.Month = $m.Month
        Render-ClassicCalendar $panel
    })

    Render-ClassicCalendar $panel
    return $panel
}

function Get-PopupLocation {
    param([System.Windows.Forms.Form]$Form,$TaskRect,[string]$Edge)

    $mid = [System.Drawing.Point]::new(
        [int](($TaskRect.Left+$TaskRect.Right)/2),
        [int](($TaskRect.Top+$TaskRect.Bottom)/2)
    )
    $work = [System.Windows.Forms.Screen]::FromPoint($mid).WorkingArea

    switch ($Edge) {
        "Top" { $x=$TaskRect.Right-$Form.Width; $y=$TaskRect.Bottom+2 }
        "Bottom" { $x=$TaskRect.Right-$Form.Width; $y=$TaskRect.Top-$Form.Height-2 }
        "Left" { $x=$TaskRect.Right+2; $y=$TaskRect.Bottom-$Form.Height }
        "Right" { $x=$TaskRect.Left-$Form.Width-2; $y=$TaskRect.Bottom-$Form.Height }
    }

    $x = [Math]::Max($work.Left,[Math]::Min($x,$work.Right-$Form.Width))
    $y = [Math]::Max($work.Top,[Math]::Min($y,$work.Bottom-$Form.Height))
    return [System.Drawing.Point]::new($x,$y)
}

function New-DateTooltipForm {
    $form = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.ShowInTaskbar = $false
    $form.TopMost = $true
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
    $form.BackColor = $classicInfo

    $label = New-Object System.Windows.Forms.Label
    $label.AutoSize = $true
    $label.Font = $classicFont
    $label.ForeColor = $classicBlack
    $label.BackColor = $classicInfo
    $label.Padding = New-Object System.Windows.Forms.Padding(4,2,4,2)
    $label.Text = (Get-Date).ToLongDateString()
    $form.Controls.Add($label)
    $form.ClientSize = New-Object System.Drawing.Size($label.PreferredWidth,$label.PreferredHeight)

    $form.Add_Paint({
        $_.Graphics.DrawRectangle([System.Drawing.Pens]::Black,0,0,$form.ClientSize.Width-1,$form.ClientSize.Height-1)
    })
    return $form
}

function New-CalendarFlyoutForm {
    $form = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    $form.ControlBox = $false
    $form.Text = ""
    $form.ShowInTaskbar = $false
    $form.TopMost = $true
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
    $form.BackColor = $classicGray
    $form.ClientSize = New-Object System.Drawing.Size(244,214)

    $calendar = New-ClassicCalendarPanel
    $calendar.Dock = [System.Windows.Forms.DockStyle]::Fill
    $form.Controls.Add($calendar)
    return $form
}

$popup = $null
$hoverStarted = $null
$leftPopupAt = $null

while ($true) {
    try {
        $taskRect = Get-RetroBarTaskbarRect
        if (-not $taskRect) {
            if ($popup) { $popup.Close(); $popup.Dispose(); $popup=$null }
            $hoverStarted = $null
            Start-Sleep -Milliseconds 300
            continue
        }

        $edge = Get-RetroBarEdge
        $clockRect = Get-ClockHitRect -TaskRect $taskRect -Edge $edge
        $cursor = Get-CursorPoint
        $overClock = $clockRect.Contains($cursor)

        if ($overClock) {
            $leftPopupAt = $null
            if (-not $hoverStarted) { $hoverStarted = [datetime]::UtcNow }

            $elapsed = ([datetime]::UtcNow - $hoverStarted).TotalMilliseconds
            if (-not $popup -and $elapsed -ge [int]$config.HoverDelayMs) {
                $popup = $(if ($config.Mode -eq "Authentic") { New-DateTooltipForm } else { New-CalendarFlyoutForm })
                $popup.Location = Get-PopupLocation -Form $popup -TaskRect $taskRect -Edge $edge
                $popup.Show()
            }
        } else {
            $hoverStarted = $null

            if ($popup) {
                if ($popup.Bounds.Contains($cursor)) {
                    $leftPopupAt = $null
                } else {
                    if (-not $leftPopupAt) { $leftPopupAt = [datetime]::UtcNow }
                    if (([datetime]::UtcNow - $leftPopupAt).TotalMilliseconds -ge [int]$config.CloseDelayMs) {
                        $popup.Close()
                        $popup.Dispose()
                        $popup = $null
                        $leftPopupAt = $null
                    }
                }
            }
        }

        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 50
    } catch {
        if ($popup) {
            try { $popup.Close(); $popup.Dispose() } catch {}
            $popup = $null
        }
        Start-Sleep -Milliseconds 500
    }
}
