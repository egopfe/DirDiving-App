param(
    [string]$OutputPath = "DIR_DIVING_Full_Feature_Presentation.pptx"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = (Resolve-Path ".").Path
$screenshotDir = Join-Path $root "Docs\FeatureScreenshots"
New-Item -ItemType Directory -Force -Path $screenshotDir | Out-Null

function Escape-Xml([string]$Text) {
    return [System.Security.SecurityElement]::Escape($Text)
}

function Add-ZipText {
    param([System.IO.Compression.ZipArchive]$Zip, [string]$Name, [string]$Content)
    $entry = $Zip.CreateEntry($Name)
    $stream = $entry.Open()
    $writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::UTF8)
    $writer.Write($Content)
    $writer.Dispose()
    $stream.Dispose()
}

function Add-ZipFile {
    param([System.IO.Compression.ZipArchive]$Zip, [string]$Name, [string]$Path)
    $entry = $Zip.CreateEntry($Name)
    $entryStream = $entry.Open()
    $fileStream = [System.IO.File]::OpenRead($Path)
    $fileStream.CopyTo($entryStream)
    $fileStream.Dispose()
    $entryStream.Dispose()
}

function New-Brush([int]$R, [int]$G, [int]$B) {
    return New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($R, $G, $B))
}

function Draw-CenteredText {
    param($G, [string]$Text, $Font, $Brush, [float]$X, [float]$Y, [float]$W, [float]$H)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = "Center"
    $sf.LineAlignment = "Center"
    $G.DrawString($Text, $Font, $Brush, (New-Object System.Drawing.RectangleF $X, $Y, $W, $H), $sf)
}

function Draw-LeftText {
    param($G, [string]$Text, $Font, $Brush, [float]$X, [float]$Y)
    $G.DrawString($Text, $Font, $Brush, $X, $Y)
}

function Draw-Button {
    param($G, [string]$Text, [float]$X, [float]$Y, [float]$W, [float]$H, $Font, $Brush, $Pen)
    $buttonBrush = New-Brush 24 58 70
    $G.FillRectangle($buttonBrush, $X, $Y, $W, $H)
    $G.DrawRectangle($Pen, $X, $Y, $W, $H)
    Draw-CenteredText $G $Text $Font $Brush $X $Y $W $H
}

function Save-WatchScreen {
    param(
        [string]$Name,
        [scriptblock]$Draw
    )

    $path = Join-Path $screenshotDir "$Name.png"
    $bmp = New-Object System.Drawing.Bitmap 390, 640
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = "AntiAlias"
    $g.TextRenderingHint = "ClearTypeGridFit"

    $bg = [System.Drawing.Color]::FromArgb(7, 24, 32)
    $g.Clear($bg)

    $palette = @{
        White = [System.Drawing.Brushes]::White
        Cyan = New-Brush 0 199 217
        Yellow = New-Brush 250 204 21
        Green = New-Brush 34 197 94
        Red = New-Brush 220 54 54
        Muted = New-Brush 155 170 176
        Card = New-Brush 18 42 52
        Button = New-Brush 24 58 70
        Line = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 110, 122), 1)
        Accent = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(0, 199, 217), 1)
    }

    $fonts = @{
        Title = New-Object System.Drawing.Font("Segoe UI", 17, [System.Drawing.FontStyle]::Bold)
        Head = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
        Body = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
        Small = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Regular)
        Button = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
        Big = New-Object System.Drawing.Font("Segoe UI", 34, [System.Drawing.FontStyle]::Bold)
        Mono = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
    }

    & $Draw $g $palette $fonts
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    return $path
}

$screens = @{}

$screens.Live = Save-WatchScreen "01-live-dive" {
    param($g, $p, $f)
    Draw-CenteredText $g "DIR DIVING" $f.Title $p.Cyan 0 18 390 30
    Draw-LeftText $g "TTV" $f.Small $p.Muted 176 70
    Draw-CenteredText $g "12.4" $f.Head $p.White 0 88 390 24
    Draw-CenteredText $g "18.6 m" $f.Big $p.White 0 116 390 62
    Draw-CenteredText $g "MAX 28.4   AVG 14.7" $f.Small $p.Muted 0 184 390 18
    $g.FillRectangle($p.Card, 28, 224, 334, 78); $g.DrawRectangle($p.Line, 28, 224, 334, 78)
    Draw-CenteredText $g "RunTime" $f.Small $p.Muted 0 232 390 16
    Draw-CenteredText $g "00:24:18" $f.Head $p.Yellow 0 252 390 28
    Draw-Button $g "START" 30 340 92 36 $f.Button $p.White $p.Accent
    Draw-Button $g "STOP" 149 340 92 36 $f.Button $p.White $p.Accent
    Draw-Button $g "RESET" 268 340 92 36 $f.Button $p.White $p.Accent
    Draw-CenteredText $g "CHR 03:12" $f.Body $p.Cyan 0 392 390 20
}

$screens.Ascent = Save-WatchScreen "02-ascent-warning" {
    param($g, $p, $f)
    Draw-CenteredText $g "ASCENT" $f.Title $p.Cyan 0 18 390 30
    Draw-CenteredText $g "RISALITA VELOCE" $f.Head $p.Red 0 72 390 28
    $g.FillRectangle($p.Card, 78, 116, 234, 310); $g.DrawRectangle($p.Line, 78, 116, 234, 310)
    $g.FillRectangle($p.Red, 110, 140, 170, 76)
    $g.FillRectangle($p.Yellow, 110, 216, 170, 82)
    $g.FillRectangle($p.Green, 110, 298, 170, 96)
    $g.FillRectangle($p.White, 104, 168, 182, 6)
    Draw-CenteredText $g "4.8 m/min" $f.Head $p.Red 0 444 390 28
    Draw-CenteredText $g "LIMIT 3.0 m/min" $f.Body $p.Muted 0 476 390 20
    Draw-CenteredText $g "HAPTIC WARNING" $f.Small $p.Yellow 0 512 390 16
}

$screens.AscentSettings = Save-WatchScreen "03-ascent-settings" {
    param($g, $p, $f)
    Draw-CenteredText $g "ASC SET" $f.Title $p.Cyan 0 18 390 30
    $rows = @(
        @("40-30 m", "10.0 m/min"),
        @("30-20 m", "5.0 m/min"),
        @("20-6 m", "3.0 m/min"),
        @("6-0 m", "1.0 m/min"),
        @("Other", "10.0 m/min")
    )
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $y = 74 + ($i * 66)
        $g.FillRectangle($p.Card, 24, $y, 342, 48); $g.DrawRectangle($p.Line, 24, $y, 342, 48)
        Draw-LeftText $g $rows[$i][0] $f.Body $p.White 38 ($y + 7)
        Draw-LeftText $g $rows[$i][1] $f.Small $p.Cyan 38 ($y + 26)
        Draw-CenteredText $g "-" $f.Button $p.White 276 ($y + 9) 28 28
        Draw-CenteredText $g "+" $f.Button $p.White 324 ($y + 9) 28 28
    }
    Draw-Button $g "RESET STD" 112 430 166 38 $f.Button $p.White $p.Accent
}

$screens.Compass = Save-WatchScreen "04-compass-bearing" {
    param($g, $p, $f)
    Draw-CenteredText $g "BUSSOLA" $f.Title $p.Cyan 0 18 390 30
    Draw-CenteredText $g "076°" $f.Big $p.White 0 86 390 62
    Draw-CenteredText $g "ENE" $f.Head $p.Yellow 0 154 390 28
    $g.DrawEllipse($p.Line, 95, 210, 200, 200)
    Draw-CenteredText $g "N" $f.Head $p.White 0 220 390 24
    Draw-CenteredText $g "BEARING 080°" $f.Body $p.Green 0 440 390 22
    Draw-Button $g "CLEAR" 132 480 126 38 $f.Button $p.White $p.Accent
}

$screens.Stopwatch = Save-WatchScreen "05-stopwatch-action" {
    param($g, $p, $f)
    Draw-CenteredText $g "STOPWATCH" $f.Title $p.Cyan 0 18 390 30
    Draw-CenteredText $g "03:12" $f.Big $p.Yellow 0 102 390 62
    Draw-Button $g "START" 46 210 90 40 $f.Button $p.White $p.Accent
    Draw-Button $g "STOP" 150 210 90 40 $f.Button $p.White $p.Accent
    Draw-Button $g "RESET" 254 210 90 40 $f.Button $p.White $p.Accent
    $g.FillRectangle($p.Card, 36, 320, 318, 96); $g.DrawRectangle($p.Line, 36, 320, 318, 96)
    Draw-CenteredText $g "Action Button intents" $f.Body $p.White 0 334 390 22
    Draw-CenteredText $g "Toggle stopwatch" $f.Small $p.Cyan 0 364 390 18
    Draw-CenteredText $g "Reset stopwatch" $f.Small $p.Cyan 0 386 390 18
}

$screens.Log = Save-WatchScreen "06-dive-log" {
    param($g, $p, $f)
    Draw-CenteredText $g "LOG" $f.Title $p.Cyan 0 18 390 30
    $rows = @(
        @("May 10, 12:10", "Max 28.4 m - 00:42:18"),
        @("May 08, 09:34", "Max 22.0 m - 00:37:02"),
        @("May 02, 15:48", "Max 31.2 m - 00:51:44")
    )
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $y = 82 + ($i * 90)
        $g.FillRectangle($p.Card, 24, $y, 342, 64); $g.DrawRectangle($p.Line, 24, $y, 342, 64)
        Draw-LeftText $g $rows[$i][0] $f.Body $p.White 40 ($y + 10)
        Draw-LeftText $g $rows[$i][1] $f.Small $p.Muted 40 ($y + 34)
    }
    Draw-CenteredText $g "Latest 40 dives stored locally" $f.Small $p.Cyan 0 384 390 18
}

$screens.Detail = Save-WatchScreen "07-dive-detail-export" {
    param($g, $p, $f)
    Draw-CenteredText $g "IMMERSIONE" $f.Title $p.Cyan 0 18 390 30
    Draw-LeftText $g "Durata" $f.Small $p.Muted 36 74; Draw-LeftText $g "00:42:18" $f.Small $p.White 286 74
    Draw-LeftText $g "Max" $f.Small $p.Muted 36 98; Draw-LeftText $g "28.4 m" $f.Small $p.White 302 98
    Draw-LeftText $g "Media" $f.Small $p.Muted 36 122; Draw-LeftText $g "14.7 m" $f.Small $p.White 302 122
    $g.FillRectangle($p.Card, 36, 166, 318, 150); $g.DrawRectangle($p.Line, 36, 166, 318, 150)
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(0,199,217), 3)
    $points = @(
        (New-Object System.Drawing.Point 46,185),
        (New-Object System.Drawing.Point 92,260),
        (New-Object System.Drawing.Point 142,245),
        (New-Object System.Drawing.Point 210,292),
        (New-Object System.Drawing.Point 282,230),
        (New-Object System.Drawing.Point 342,190)
    )
    $g.DrawLines($pen, $points)
    Draw-Button $g "CSV SUBSURFACE" 82 352 226 38 $f.Button $p.White $p.Accent
    Draw-Button $g "SHARE CSV" 112 404 166 38 $f.Button $p.White $p.Accent
}

$screens.GPS = Save-WatchScreen "08-gps-entry-exit" {
    param($g, $p, $f)
    Draw-CenteredText $g "GPS" $f.Title $p.Cyan 0 18 390 30
    $g.FillRectangle($p.Card, 32, 88, 326, 118); $g.DrawRectangle($p.Line, 32, 88, 326, 118)
    Draw-CenteredText $g "ENTRY POINT" $f.Body $p.Green 0 102 390 22
    Draw-CenteredText $g "38.115420, 13.361920" $f.Mono $p.White 0 134 390 22
    Draw-CenteredText $g "best effort surface fix" $f.Small $p.Muted 0 164 390 18
    $g.FillRectangle($p.Card, 32, 250, 326, 118); $g.DrawRectangle($p.Line, 32, 250, 326, 118)
    Draw-CenteredText $g "EXIT POINT" $f.Body $p.Yellow 0 264 390 22
    Draw-CenteredText $g "38.117008, 13.359110" $f.Mono $p.White 0 296 390 22
    Draw-CenteredText $g "saved after capture window" $f.Small $p.Muted 0 326 390 18
}

$screens.UserImages = Save-WatchScreen "09-user-images" {
    param($g, $p, $f)
    Draw-CenteredText $g "SCHERMI" $f.Title $p.Cyan 0 18 390 30
    $rows = @("Checklist-pre-dive.png", "Gas-plan.jpg", "Emergency-card.png", "Deco-table.heic")
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $y = 86 + ($i * 70)
        $g.FillRectangle($p.Card, 24, $y, 342, 48); $g.DrawRectangle($p.Line, 24, $y, 342, 48)
        Draw-LeftText $g $rows[$i] $f.Body $p.White 40 ($y + 14)
    }
    Draw-CenteredText $g "Bundled reference images" $f.Small $p.Muted 0 402 390 18
}

$screens.BuddySend = Save-WatchScreen "10-buddy-send" {
    param($g, $p, $f)
    Draw-CenteredText $g "BUDDY ASSIST" $f.Title $p.Cyan 0 14 390 30
    Draw-CenteredText $g "CONNECTED" $f.Small $p.Green 0 46 390 16
    Draw-CenteredText $g "Indicazione di prossimità sperimentale" $f.Small $p.Yellow 0 78 390 14
    Draw-LeftText $g "Buddy Link" $f.Button $p.White 30 122
    Draw-LeftText $g "ONLINE" $f.Button $p.Green 306 122
    $messages = @("OK", "RISALI", "HO UN PROBLEMA", "DOVE SEI?", "TORNA INDIETRO", "LOW GAS")
    for($i=0;$i -lt $messages.Count;$i++){
        $col=$i%2; $row=[math]::Floor($i/2); $x=24+($col*174); $y=188+($row*56)
        Draw-Button $g $messages[$i] $x $y 150 38 $f.Button $p.White $p.Accent
    }
    Draw-Button $g "PAIR" 72 396 96 32 $f.Button $p.White $p.Accent
    Draw-Button $g "STOP" 222 396 96 32 $f.Button $p.White $p.Accent
}

$screens.BuddyAnswer = Save-WatchScreen "11-buddy-answer" {
    param($g, $p, $f)
    Draw-CenteredText $g "BUDDY ASSIST" $f.Title $p.Cyan 0 14 390 30
    $g.FillRectangle($p.Red, 22, 80, 346, 90); $g.DrawRectangle([System.Drawing.Pens]::White, 22, 80, 346, 90)
    Draw-CenteredText $g "MESSAGGIO BUDDY" $f.Small $p.White 0 88 390 14
    Draw-CenteredText $g "LOW GAS" $f.Title $p.White 0 110 390 32
    Draw-Button $g "ANSWER" 88 140 82 24 $f.Button $p.White $p.Accent
    Draw-Button $g "OK" 220 140 82 24 $f.Button $p.White $p.Accent
    Draw-LeftText $g "ANSWER" $f.Button $p.Yellow 24 194
    $messages = @("OK", "RISALI", "HO UN PROBLEMA", "DOVE SEI?", "TORNA INDIETRO", "LOW GAS")
    for($i=0;$i -lt $messages.Count;$i++){
        $col=$i%2; $row=[math]::Floor($i/2); $x=24+($col*174); $y=224+($row*56)
        Draw-Button $g $messages[$i] $x $y 150 38 $f.Button $p.White $p.Accent
    }
}

$screens.BuddyLink = Save-WatchScreen "12-buddy-link-compass" {
    param($g, $p, $f)
    Draw-CenteredText $g "BUDDY LINK" $f.Title $p.Cyan 0 14 390 30
    Draw-LeftText $g "Status" $f.Body $p.White 30 74
    Draw-LeftText $g "ONLINE" $f.Button $p.Green 292 74
    $g.FillEllipse($p.Green, 32, 112, 28, 28); $g.DrawEllipse([System.Drawing.Pens]::White,32,112,28,28)
    Draw-LeftText $g "NEAR" $f.Button $p.Green 74 106
    Draw-LeftText $g "PING 15s RSSI -58" $f.Small $p.Muted 74 126
    $g.FillRectangle($p.Card, 24, 176, 342, 132); $g.DrawRectangle($p.Line, 24, 176, 342, 132)
    Draw-LeftText $g "BUSSOLA" $f.Button $p.Cyan 38 188
    Draw-LeftText $g "Ultima direzione" $f.Small $p.Muted 38 216; Draw-LeftText $g "074°" $f.Small $p.White 308 216
    Draw-LeftText $g "Bearing condiviso" $f.Small $p.Muted 38 238; Draw-LeftText $g "080°" $f.Small $p.White 308 238
    Draw-LeftText $g "Heading" $f.Small $p.Muted 38 260; Draw-LeftText $g "076°" $f.Small $p.White 308 260
    Draw-LeftText $g "Direzione plausibile" $f.Button $p.White 38 286; Draw-LeftText $g "080°" $f.Button $p.Yellow 308 286
}

$features = @(
    @{ Title="Project Overview"; Bullets=@("DIR DIVING is a SwiftUI watchOS dive app for Apple Watch Ultra-class devices.","The project covers live dive data, navigation, logs, export, configurable limits, and experimental buddy workflows."); Image=$screens.Live; Accent="00C7D9" },
    @{ Title="Live Dive Screen"; Bullets=@("Shows current, maximum, and average depth.","Displays water temperature, RunTime, TTV, and warning state.","Built for glanceable underwater readability."); Image=$screens.Live; Accent="00C7D9" },
    @{ Title="Ascent Warning"; Bullets=@("Calculates ascent rate from consecutive depth samples.","Uses green, yellow, and red zones.","Triggers red visual warning and haptic feedback when over limit."); Image=$screens.Ascent; Accent="EF4444" },
    @{ Title="Configurable Ascent Limits"; Bullets=@("Diver can edit each depth-band ascent limit on Apple Watch.","Values persist locally through UserDefaults.","Reset returns the profile to standard limits."); Image=$screens.AscentSettings; Accent="FACC15" },
    @{ Title="Compass and Bearing"; Bullets=@("Full compass screen with heading and cardinal direction.","SET BEARING and CLEAR actions are contextual.","CoreLocation heading updates drive the display."); Image=$screens.Compass; Accent="36D399" },
    @{ Title="Manual Stopwatch and Action Button"; Bullets=@("Manual stopwatch is separate from automatic RunTime.","START, STOP, and RESET are available on screen.","App Intents support stopwatch workflows and Buddy Assist access."); Image=$screens.Stopwatch; Accent="60A5FA" },
    @{ Title="Dive Log"; Bullets=@("Stores the latest 40 dives locally.","Sessions include duration, depths, temperatures, GPS metadata, and samples.","Log entries are sorted by start date."); Image=$screens.Log; Accent="A78BFA" },
    @{ Title="Dive Detail and Subsurface Export"; Bullets=@("Dive detail shows metrics and a profile chart.","CSV generation supports Subsurface import workflows.","ShareLink sends CSV to Files, AirDrop, email, or companion devices."); Image=$screens.Detail; Accent="22D3EE" },
    @{ Title="GPS Entry and Exit"; Bullets=@("Captures surface entry and exit coordinates.","Uses a best-effort capture window for better fixes.","GPS is metadata only, not underwater tracking."); Image=$screens.GPS; Accent="34D399" },
    @{ Title="User Images"; Bullets=@("Displays bundled PNG, JPG, JPEG, or HEIC reference screens.","Useful for checklists, procedures, tables, and static reminders.","Future path can use WatchConnectivity from an iPhone companion app."); Image=$screens.UserImages; Accent="FB923C" },
    @{ Title="Buddy Assist Messaging"; Bullets=@("Preset buddy messages: OK, RISALI, HO UN PROBLEMA, DOVE SEI?, TORNA INDIETRO, LOW GAS.","UI supports pairing state and send controls.","CoreBluetooth central-side scaffold is experimental."); Image=$screens.BuddySend; Accent="00C7D9" },
    @{ Title="Received Message and Answer"; Bullets=@("Incoming buddy messages appear in a large banner.","Critical messages are highlighted in red and trigger failure haptics.","ANSWER opens the same preset message set for immediate reply."); Image=$screens.BuddyAnswer; Accent="EF4444" },
    @{ Title="Buddy Link and Plausible Direction"; Bullets=@("Buddy Link shows ONLINE or LOST.","Signal dot uses green, yellow, and red state.","Compass block combines last known direction, shared bearing, and heading into a plausible direction."); Image=$screens.BuddyLink; Accent="36D399" },
    @{ Title="Experimental Safety Position"; Bullets=@("Buddy proximity and BLE messaging are not certified safety systems.","watchOS cannot advertise BLE services through CBPeripheralManager, limiting pure Watch-to-Watch BLE.","Hardware validation and a relay or revised architecture may be required."); Image=$screens.BuddyLink; Accent="FB923C" }
)

function Text-Shape {
    param([int]$Id, [string]$Name, [int]$X, [int]$Y, [int]$Cx, [int]$Cy, [string[]]$Lines, [int]$Size, [string]$Color, [bool]$Bold=$false)
    $paragraphs = foreach ($line in $Lines) {
        $escaped = Escape-Xml $line
        $boldAttr = if ($Bold) { ' b="1"' } else { "" }
        "<a:p><a:r><a:rPr lang=`"en-US`" sz=`"$Size`"$boldAttr><a:solidFill><a:srgbClr val=`"$Color`"/></a:solidFill></a:rPr><a:t>$escaped</a:t></a:r><a:endParaRPr lang=`"en-US`" sz=`"$Size`"/></a:p>"
    }
    $body = [string]::Join("", $paragraphs)
@"
<p:sp>
  <p:nvSpPr><p:cNvPr id="$Id" name="$Name"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
  <p:spPr><a:xfrm><a:off x="$X" y="$Y"/><a:ext cx="$Cx" cy="$Cy"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></p:spPr>
  <p:txBody><a:bodyPr wrap="square"/><a:lstStyle/>$body</p:txBody>
</p:sp>
"@
}

function Image-Shape {
    param([int]$Id, [string]$RelId)
@"
<p:pic>
  <p:nvPicPr><p:cNvPr id="$Id" name="Feature screenshot"/><p:cNvPicPr/><p:nvPr/></p:nvPicPr>
  <p:blipFill><a:blip r:embed="$RelId"/><a:stretch><a:fillRect/></a:stretch></p:blipFill>
  <p:spPr><a:xfrm><a:off x="5943600" y="487680"/><a:ext cx="2159000" cy="3543300"/></a:xfrm><a:prstGeom prst="roundRect"><a:avLst/></a:prstGeom><a:ln w="12700"><a:solidFill><a:srgbClr val="00C7D9"/></a:solidFill></a:ln></p:spPr>
</p:pic>
"@
}

function Slide-Xml {
    param([string]$Title, [string[]]$Bullets, [string]$Accent, [int]$Index)
    $titleShape = Text-Shape -Id 2 -Name "Title" -X 457200 -Y 304800 -Cx 4876800 -Cy 609600 -Lines @($Title) -Size 3300 -Color "FFFFFF" -Bold $true
    $bulletLines = $Bullets | ForEach-Object { "- $_" }
    $bodyShape = Text-Shape -Id 3 -Name "Body" -X 609600 -Y 1117600 -Cx 4876800 -Cy 3048000 -Lines $bulletLines -Size 1900 -Color "DDEAF0"
    $imageShape = Image-Shape -Id 4 -RelId "rId2"
@"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:bg><p:bgPr><a:solidFill><a:srgbClr val="071820"/></a:solidFill><a:effectLst/></p:bgPr></p:bg>
    <p:spTree>
      <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
      <p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>
      <p:sp><p:nvSpPr><p:cNvPr id="10" name="Accent bar"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="9144000" cy="152400"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:solidFill><a:srgbClr val="$Accent"/></a:solidFill><a:ln><a:noFill/></a:ln></p:spPr></p:sp>
      $titleShape
      $bodyShape
      $imageShape
    </p:spTree>
  </p:cSld>
  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
</p:sld>
"@
}

$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
if (Test-Path $outputFullPath) { Remove-Item -LiteralPath $outputFullPath -Force }

$fs = [System.IO.File]::Open($outputFullPath, [System.IO.FileMode]::CreateNew)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)

try {
    $slideOverrides = for ($i=1; $i -le $features.Count; $i++) { "<Override PartName=`"/ppt/slides/slide$i.xml`" ContentType=`"application/vnd.openxmlformats-officedocument.presentationml.slide+xml`"/>" }
    $slideOverrideText = [string]::Join("", $slideOverrides)
    Add-ZipText $zip "[Content_Types].xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
  <Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>
  <Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
  <Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
  <Override PartName="/ppt/presProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presProps+xml"/>
  <Override PartName="/ppt/viewProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  $slideOverrideText
</Types>
"@
    Add-ZipText $zip "_rels/.rels" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
"@
    $slideIds = for ($i=1; $i -le $features.Count; $i++) { "<p:sldId id=`"$($i+255)`" r:id=`"rId$i`"/>" }
    Add-ZipText $zip "ppt/presentation.xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId$($features.Count+1)"/></p:sldMasterIdLst>
  <p:sldIdLst>$([string]::Join("", $slideIds))</p:sldIdLst>
  <p:sldSz cx="9144000" cy="5143500" type="screen16x9"/>
  <p:notesSz cx="6858000" cy="9144000"/>
  <p:defaultTextStyle/>
</p:presentation>
"@
    $rels = for ($i=1; $i -le $features.Count; $i++) { "<Relationship Id=`"rId$i`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide`" Target=`"slides/slide$i.xml`"/>" }
    $rels += "<Relationship Id=`"rId$($features.Count+1)`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster`" Target=`"slideMasters/slideMaster1.xml`"/>"
    $rels += "<Relationship Id=`"rId$($features.Count+2)`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme`" Target=`"theme/theme1.xml`"/>"
    $relsText = [string]::Join("", $rels)
    Add-ZipText $zip "ppt/_rels/presentation.xml.rels" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">$relsText</Relationships>
"@

    Add-ZipText $zip "ppt/slideMasters/slideMaster1.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><p:sldMaster xmlns:a=`"http://schemas.openxmlformats.org/drawingml/2006/main`" xmlns:r=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships`" xmlns:p=`"http://schemas.openxmlformats.org/presentationml/2006/main`"><p:cSld><p:spTree><p:nvGrpSpPr><p:cNvPr id=`"1`" name=`"`"/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x=`"0`" y=`"0`"/><a:ext cx=`"0`" cy=`"0`"/><a:chOff x=`"0`" y=`"0`"/><a:chExt cx=`"0`" cy=`"0`"/></a:xfrm></p:grpSpPr></p:spTree></p:cSld><p:clrMap bg1=`"lt1`" tx1=`"dk1`" bg2=`"lt2`" tx2=`"dk2`" accent1=`"accent1`" accent2=`"accent2`" accent3=`"accent3`" accent4=`"accent4`" accent5=`"accent5`" accent6=`"accent6`" hlink=`"hlink`" folHlink=`"folHlink`"/><p:sldLayoutIdLst><p:sldLayoutId id=`"2147483649`" r:id=`"rId1`"/></p:sldLayoutIdLst></p:sldMaster>"
    Add-ZipText $zip "ppt/slideMasters/_rels/slideMaster1.xml.rels" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><Relationships xmlns=`"http://schemas.openxmlformats.org/package/2006/relationships`"><Relationship Id=`"rId1`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout`" Target=`"../slideLayouts/slideLayout1.xml`"/><Relationship Id=`"rId2`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme`" Target=`"../theme/theme1.xml`"/></Relationships>"
    Add-ZipText $zip "ppt/slideLayouts/slideLayout1.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><p:sldLayout xmlns:a=`"http://schemas.openxmlformats.org/drawingml/2006/main`" xmlns:r=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships`" xmlns:p=`"http://schemas.openxmlformats.org/presentationml/2006/main`" type=`"blank`" preserve=`"1`"><p:cSld name=`"Blank`"><p:spTree><p:nvGrpSpPr><p:cNvPr id=`"1`" name=`"`"/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x=`"0`" y=`"0`"/><a:ext cx=`"0`" cy=`"0`"/><a:chOff x=`"0`" y=`"0`"/><a:chExt cx=`"0`" cy=`"0`"/></a:xfrm></p:grpSpPr></p:spTree></p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sldLayout>"
    Add-ZipText $zip "ppt/slideLayouts/_rels/slideLayout1.xml.rels" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><Relationships xmlns=`"http://schemas.openxmlformats.org/package/2006/relationships`"><Relationship Id=`"rId1`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster`" Target=`"../slideMasters/slideMaster1.xml`"/></Relationships>"
    Add-ZipText $zip "ppt/theme/theme1.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><a:theme xmlns:a=`"http://schemas.openxmlformats.org/drawingml/2006/main`" name=`"DIR DIVING`"><a:themeElements><a:clrScheme name=`"DIR DIVING`"><a:dk1><a:srgbClr val=`"071820`"/></a:dk1><a:lt1><a:srgbClr val=`"FFFFFF`"/></a:lt1><a:dk2><a:srgbClr val=`"0F2A36`"/></a:dk2><a:lt2><a:srgbClr val=`"DDEAF0`"/></a:lt2><a:accent1><a:srgbClr val=`"00C7D9`"/></a:accent1><a:accent2><a:srgbClr val=`"36D399`"/></a:accent2><a:accent3><a:srgbClr val=`"FACC15`"/></a:accent3><a:accent4><a:srgbClr val=`"EF4444`"/></a:accent4><a:accent5><a:srgbClr val=`"60A5FA`"/></a:accent5><a:accent6><a:srgbClr val=`"A78BFA`"/></a:accent6><a:hlink><a:srgbClr val=`"60A5FA`"/></a:hlink><a:folHlink><a:srgbClr val=`"A78BFA`"/></a:folHlink></a:clrScheme><a:fontScheme name=`"DIR DIVING`"><a:majorFont><a:latin typeface=`"Aptos Display`"/></a:majorFont><a:minorFont><a:latin typeface=`"Aptos`"/></a:minorFont></a:fontScheme><a:fmtScheme name=`"DIR DIVING`"><a:fillStyleLst><a:solidFill><a:schemeClr val=`"phClr`"/></a:solidFill></a:fillStyleLst><a:lnStyleLst><a:ln w=`"6350`"><a:solidFill><a:schemeClr val=`"phClr`"/></a:solidFill></a:ln></a:lnStyleLst><a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst><a:bgFillStyleLst><a:solidFill><a:schemeClr val=`"phClr`"/></a:solidFill></a:bgFillStyleLst></a:fmtScheme></a:themeElements></a:theme>"
    Add-ZipText $zip "ppt/presProps.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><p:presentationPr xmlns:p=`"http://schemas.openxmlformats.org/presentationml/2006/main`"/>"
    Add-ZipText $zip "ppt/viewProps.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><p:viewPr xmlns:p=`"http://schemas.openxmlformats.org/presentationml/2006/main`"/>"
    $created = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    Add-ZipText $zip "docProps/core.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><cp:coreProperties xmlns:cp=`"http://schemas.openxmlformats.org/package/2006/metadata/core-properties`" xmlns:dc=`"http://purl.org/dc/elements/1.1/`" xmlns:dcterms=`"http://purl.org/dc/terms/`" xmlns:dcmitype=`"http://purl.org/dc/dcmitype/`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><dc:title>DIR DIVING Full Feature Presentation</dc:title><dc:creator>DIR DIVING</dc:creator><cp:lastModifiedBy>DIR DIVING</cp:lastModifiedBy><dcterms:created xsi:type=`"dcterms:W3CDTF`">$created</dcterms:created><dcterms:modified xsi:type=`"dcterms:W3CDTF`">$created</dcterms:modified></cp:coreProperties>"
    Add-ZipText $zip "docProps/app.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><Properties xmlns=`"http://schemas.openxmlformats.org/officeDocument/2006/extended-properties`" xmlns:vt=`"http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes`"><Application>DIR DIVING</Application><PresentationFormat>On-screen Show (16:9)</PresentationFormat><Slides>$($features.Count)</Slides></Properties>"

    for ($i=1; $i -le $features.Count; $i++) {
        $feature = $features[$i-1]
        Add-ZipText $zip "ppt/slides/slide$i.xml" (Slide-Xml -Title $feature.Title -Bullets $feature.Bullets -Accent $feature.Accent -Index $i)
        Add-ZipText $zip "ppt/slides/_rels/slide$i.xml.rels" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="../media/image$i.png"/>
</Relationships>
"@
        Add-ZipFile $zip "ppt/media/image$i.png" $feature.Image
    }
}
finally {
    $zip.Dispose()
    $fs.Dispose()
}

Write-Host "Created $outputFullPath"
Write-Host "Screenshots in $screenshotDir"
