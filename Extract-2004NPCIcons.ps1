# ---------------------------------------------
# Extract 2004 RuneScape NPC icons from the
# LostHQ NPC spritesheet using NPC ID as tile index.
# ---------------------------------------------

Add-Type -AssemblyName System.Drawing

$BaseDir   = "C:\2004-Runescape-DPS-Calculator-Rev-254"
$OutputDir = Join-Path $BaseDir "npc_icons"
$SheetPath = Join-Path $BaseDir "npc_spritesheet.png"

$SheetUrl  = "https://2004.losthq.rs/img/npc_spritesheet.png"

# Create output directory if missing
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Download spritesheet if missing
if (!(Test-Path $SheetPath)) {
    Write-Host "Downloading NPC spritesheet..."
    Invoke-WebRequest -Uri $SheetUrl -OutFile $SheetPath
}

# Load spritesheet
$sheet = [System.Drawing.Bitmap]::FromFile($SheetPath)

$tileSize = 32
$columns  = [math]::Floor($sheet.Width / $tileSize)
$rows     = [math]::Floor($sheet.Height / $tileSize)
$total    = $columns * $rows

Write-Host "NPC spritesheet loaded: $columns columns × $rows rows ($total tiles)"

# Extract each tile
for ($id = 0; $id -lt $total; $id++) {

    $col = $id % $columns
    $row = [math]::Floor($id / $columns)

    $sx = $col * $tileSize
    $sy = $row * $tileSize

    $rect = New-Object System.Drawing.Rectangle $sx, $sy, $tileSize, $tileSize
    $tile = New-Object System.Drawing.Bitmap $tileSize, $tileSize
    $graphics = [System.Drawing.Graphics]::FromImage($tile)

    $graphics.DrawImage($sheet, 0, 0, $rect, [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()

    $outPath = Join-Path $OutputDir "$id.png"
    $tile.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $tile.Dispose()

    Write-Progress -Activity "Extracting NPC icons" `
                   -Status "NPC Tile $id" `
                   -PercentComplete (($id / $total) * 100)
}

$sheet.Dispose()

Write-Host "Done. Extracted $total NPC icons to: $OutputDir"
