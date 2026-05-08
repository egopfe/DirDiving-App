param(
    [string]$OutputPath = "DIR_DIVING_Project_Presentation.pptx"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Escape-Xml([string]$Text) {
    return [System.Security.SecurityElement]::Escape($Text)
}

function Add-ZipEntry {
    param(
        [System.IO.Compression.ZipArchive]$Zip,
        [string]$Name,
        [string]$Content
    )
    $entry = $Zip.CreateEntry($Name)
    $stream = $entry.Open()
    $writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::UTF8)
    $writer.Write($Content)
    $writer.Dispose()
    $stream.Dispose()
}

function Shape-Xml {
    param(
        [int]$Id,
        [string]$Name,
        [int]$X,
        [int]$Y,
        [int]$Cx,
        [int]$Cy,
        [string[]]$Lines,
        [int]$FontSize = 2400,
        [bool]$Bold = $false,
        [string]$Color = "FFFFFF"
    )

    $paragraphs = foreach ($line in $Lines) {
        $escaped = Escape-Xml $line
        $boldAttr = if ($Bold) { ' b="1"' } else { "" }
        "<a:p><a:r><a:rPr lang=`"en-US`" sz=`"$FontSize`"$boldAttr><a:solidFill><a:srgbClr val=`"$Color`"/></a:solidFill></a:rPr><a:t>$escaped</a:t></a:r><a:endParaRPr lang=`"en-US`" sz=`"$FontSize`"/></a:p>"
    }
    $body = [string]::Join("", $paragraphs)

    return @"
<p:sp>
  <p:nvSpPr><p:cNvPr id="$Id" name="$Name"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
  <p:spPr><a:xfrm><a:off x="$X" y="$Y"/><a:ext cx="$Cx" cy="$Cy"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></p:spPr>
  <p:txBody><a:bodyPr wrap="square"/><a:lstStyle/>$body</p:txBody>
</p:sp>
"@
}

function Slide-Xml {
    param(
        [string]$Title,
        [string[]]$Bullets,
        [string]$Accent = "00C7D9"
    )

    $titleShape = Shape-Xml -Id 2 -Name "Title" -X 457200 -Y 342900 -Cx 8229600 -Cy 914400 -Lines @($Title) -FontSize 3600 -Bold $true -Color "FFFFFF"
    $bulletLines = $Bullets | ForEach-Object { "- $_" }
    $bodyShape = Shape-Xml -Id 3 -Name "Body" -X 609600 -Y 1371600 -Cx 7924800 -Cy 3657600 -Lines $bulletLines -FontSize 2200 -Color "DDEAF0"

    return @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:bg><p:bgPr><a:solidFill><a:srgbClr val="071820"/></a:solidFill><a:effectLst/></p:bgPr></p:bg>
    <p:spTree>
      <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
      <p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>
      <p:sp>
        <p:nvSpPr><p:cNvPr id="10" name="Accent bar"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr>
        <p:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="9144000" cy="152400"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:solidFill><a:srgbClr val="$Accent"/></a:solidFill><a:ln><a:noFill/></a:ln></p:spPr>
      </p:sp>
      $titleShape
      $bodyShape
    </p:spTree>
  </p:cSld>
  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
</p:sld>
"@
}

$slides = @(
    @{ Title = "DIR DIVING"; Bullets = @("SwiftUI watchOS dive app for Apple Watch Ultra-class devices", "Live depth, ascent-rate awareness, compass, dive log, GPS entry/exit metadata", "Built for practical underwater readability and simple watch-first workflows"); Accent = "00C7D9" },
    @{ Title = "The Problem"; Bullets = @("Divers need compact, glanceable data on the wrist", "Critical ascent-rate feedback must be immediate", "Entry and exit GPS points matter, but underwater GPS is unreliable", "Export should remain compatible with established dive-log tools"); Accent = "36D399" },
    @{ Title = "Core Experience"; Bullets = @("Vertical page navigation with the Digital Crown", "Live dive screen with depth, temperature, RunTime, TTV, stopwatch, and ascent gauge", "Compass screen with contextual SET BEARING and CLEAR actions", "Local log screen for the latest 40 dives"); Accent = "FACC15" },
    @{ Title = "Safety-Oriented Feedback"; Bullets = @("Depth-band ascent limits: 10, 5, 3, and 1 m/min", "Red warning state when ascent rate exceeds the current band", "Haptic .failure feedback throttled to one warning every 2 seconds", "Fallback limit above configured bands intentionally remains 10 m/min"); Accent = "EF4444" },
    @{ Title = "GPS Entry and Exit"; Bullets = @("The app stores the latest available surface location immediately", "A 6-second best-effort capture window updates the point if a better fix arrives", "Exit logs are finalized after the best-effort capture completes", "GPS metadata is surface entry/exit data, not underwater tracking"); Accent = "60A5FA" },
    @{ Title = "Logging and Export"; Bullets = @("Dive sessions are stored locally as JSON", "Each session contains duration, depths, temperatures, GPS metadata, and samples", "CSV export supports Subsurface import workflows", "Shared CSV files include time, depth, temperature, and coordinates when available"); Accent = "A78BFA" },
    @{ Title = "Architecture"; Bullets = @("Models define sessions, samples, GPS points, and ascent status", "Services handle submersion, GPS, compass, haptics, export, images, and App Intents", "Views are compact SwiftUI watch screens", "XcodeGen project configuration lives in project.yml"); Accent = "22D3EE" },
    @{ Title = "Current Status"; Bullets = @("Depth/submersion entitlement is pending", "Entitlements file is present and ready to update after Apple approval", "Final watchOS validation must be performed on macOS with Xcode", "Codebase has been cleaned up and documentation is now in English"); Accent = "FB923C" },
    @{ Title = "Roadmap"; Bullets = @("Add approved water depth entitlement and validate on Apple Watch hardware", "Improve Subsurface metadata mapping if needed", "Consider iPhone companion sync for user images", "Add automated tests around formatters, ascent-rate logic, and export generation"); Accent = "34D399" }
)

$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
if (Test-Path $outputFullPath) {
    Remove-Item -LiteralPath $outputFullPath -Force
}

$fs = [System.IO.File]::Open($outputFullPath, [System.IO.FileMode]::CreateNew)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)

try {
    $slideOverrides = for ($i = 1; $i -le $slides.Count; $i++) {
        "<Override PartName=`"/ppt/slides/slide$i.xml`" ContentType=`"application/vnd.openxmlformats-officedocument.presentationml.slide+xml`"/>"
    }
    $slideOverridesText = [string]::Join("", $slideOverrides)

    Add-ZipEntry $zip "[Content_Types].xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
  <Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>
  <Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
  <Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
  <Override PartName="/ppt/presProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presProps+xml"/>
  <Override PartName="/ppt/viewProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  $slideOverridesText
</Types>
"@

    Add-ZipEntry $zip "_rels/.rels" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
"@

    $slideIdList = for ($i = 1; $i -le $slides.Count; $i++) {
        $slideId = 255 + $i
        "<p:sldId id=`"$slideId`" r:id=`"rId$i`"/>"
    }
    $slideIdListText = [string]::Join("", $slideIdList)

    Add-ZipEntry $zip "ppt/presentation.xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId$($slides.Count + 1)"/></p:sldMasterIdLst>
  <p:sldIdLst>$slideIdListText</p:sldIdLst>
  <p:sldSz cx="9144000" cy="5143500" type="screen16x9"/>
  <p:notesSz cx="6858000" cy="9144000"/>
  <p:defaultTextStyle/>
</p:presentation>
"@

    $presentationRels = for ($i = 1; $i -le $slides.Count; $i++) {
        "<Relationship Id=`"rId$i`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide`" Target=`"slides/slide$i.xml`"/>"
    }
    $presentationRels += "<Relationship Id=`"rId$($slides.Count + 1)`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster`" Target=`"slideMasters/slideMaster1.xml`"/>"
    $presentationRels += "<Relationship Id=`"rId$($slides.Count + 2)`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/presProps`" Target=`"presProps.xml`"/>"
    $presentationRels += "<Relationship Id=`"rId$($slides.Count + 3)`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/viewProps`" Target=`"viewProps.xml`"/>"
    $presentationRels += "<Relationship Id=`"rId$($slides.Count + 4)`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme`" Target=`"theme/theme1.xml`"/>"
    $presentationRelsText = [string]::Join("", $presentationRels)

    Add-ZipEntry $zip "ppt/_rels/presentation.xml.rels" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">$presentationRelsText</Relationships>
"@

    Add-ZipEntry $zip "ppt/slideMasters/slideMaster1.xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldMaster xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr></p:spTree></p:cSld>
  <p:clrMap bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" accent1="accent1" accent2="accent2" accent3="accent3" accent4="accent4" accent5="accent5" accent6="accent6" hlink="hlink" folHlink="folHlink"/>
  <p:sldLayoutIdLst><p:sldLayoutId id="2147483649" r:id="rId1"/></p:sldLayoutIdLst>
</p:sldMaster>
"@

    Add-ZipEntry $zip "ppt/slideMasters/_rels/slideMaster1.xml.rels" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/>
</Relationships>
"@

    Add-ZipEntry $zip "ppt/slideLayouts/slideLayout1.xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldLayout xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" type="blank" preserve="1">
  <p:cSld name="Blank"><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr></p:spTree></p:cSld>
  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
</p:sldLayout>
"@

    Add-ZipEntry $zip "ppt/slideLayouts/_rels/slideLayout1.xml.rels" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="../slideMasters/slideMaster1.xml"/>
</Relationships>
"@

    Add-ZipEntry $zip "ppt/theme/theme1.xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="DIR DIVING">
  <a:themeElements>
    <a:clrScheme name="DIR DIVING"><a:dk1><a:srgbClr val="071820"/></a:dk1><a:lt1><a:srgbClr val="FFFFFF"/></a:lt1><a:dk2><a:srgbClr val="0F2A36"/></a:dk2><a:lt2><a:srgbClr val="DDEAF0"/></a:lt2><a:accent1><a:srgbClr val="00C7D9"/></a:accent1><a:accent2><a:srgbClr val="36D399"/></a:accent2><a:accent3><a:srgbClr val="FACC15"/></a:accent3><a:accent4><a:srgbClr val="EF4444"/></a:accent4><a:accent5><a:srgbClr val="60A5FA"/></a:accent5><a:accent6><a:srgbClr val="A78BFA"/></a:accent6><a:hlink><a:srgbClr val="60A5FA"/></a:hlink><a:folHlink><a:srgbClr val="A78BFA"/></a:folHlink></a:clrScheme>
    <a:fontScheme name="DIR DIVING"><a:majorFont><a:latin typeface="Aptos Display"/></a:majorFont><a:minorFont><a:latin typeface="Aptos"/></a:minorFont></a:fontScheme>
    <a:fmtScheme name="DIR DIVING"><a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:fillStyleLst><a:lnStyleLst><a:ln w="6350"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln></a:lnStyleLst><a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst><a:bgFillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:bgFillStyleLst></a:fmtScheme>
  </a:themeElements>
</a:theme>
"@

    Add-ZipEntry $zip "ppt/presProps.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><p:presentationPr xmlns:p=`"http://schemas.openxmlformats.org/presentationml/2006/main`"/>"
    Add-ZipEntry $zip "ppt/viewProps.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><p:viewPr xmlns:p=`"http://schemas.openxmlformats.org/presentationml/2006/main`"/>"

    $created = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    Add-ZipEntry $zip "docProps/core.xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>DIR DIVING Project Presentation</dc:title>
  <dc:creator>DIR DIVING</dc:creator>
  <cp:lastModifiedBy>DIR DIVING</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">$created</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">$created</dcterms:modified>
</cp:coreProperties>
"@

    Add-ZipEntry $zip "docProps/app.xml" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>DIR DIVING</Application>
  <PresentationFormat>On-screen Show (16:9)</PresentationFormat>
  <Slides>$($slides.Count)</Slides>
</Properties>
"@

    for ($i = 1; $i -le $slides.Count; $i++) {
        $slide = $slides[$i - 1]
        Add-ZipEntry $zip "ppt/slides/slide$i.xml" (Slide-Xml -Title $slide.Title -Bullets $slide.Bullets -Accent $slide.Accent)
        Add-ZipEntry $zip "ppt/slides/_rels/slide$i.xml.rels" @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
</Relationships>
"@
    }
}
finally {
    $zip.Dispose()
    $fs.Dispose()
}

Write-Host "Created $outputFullPath"
