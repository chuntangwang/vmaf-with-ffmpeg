$host.ui.RawUI.WindowTitle = "Create Sample NVENC H265"
# -----------------------------------------------------------------------------
function Join-EnvPath {
    param (
        [Parameter(Mandatory)][string]
        $Path
    )
    # Check if the directory exists
    if (Test-Path $Path) {
        # Check if the directory is already in the Path
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $newPath = $currentPath -split ';' | Where-Object { $_ -eq $Path }
        if ($newPath) {
            Write-Host "Directory $Path already exists in `$env:Path."
        } else {
            # If it's not in the Path, add it
            $newPath = "$currentPath;$Path"
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            Write-Host "Directory $Path added to `$env:Path successfully."
        }
    } else {
        Throw "Directory $Path does not exist."
    }
}

# ffmpeg path
Join-EnvPath -Path "C:\apps\ffmpeg\"

# -----------------------------------------------------------------------------
$input    = $args[0]
$bitrate  = $args[1]
$scale    = $args[2]

$codec    = "hevc_nvenc"
$fps      = 24

# "ffmpeg -h encoder=libx265" or "x265 --fullhelp"
$csp        = "format=yuv420p"
$vformat    = "$csp"
$vprofile   = "main"
$vpreset    = "p1"
$vlevel     = 3.1
$vtune      = "ull"

$output_prefix = ("$input" | Select-String -Pattern ".*[a-z]_.*[0-9]s").Matches.Value
$output = "${output_prefix}_${bitrate}_${scale}_NVENC_H265.flv"

ffmpeg -hide_banner -hwaccel cuda `
-i "$input" `
-vf $vformat -c:v $codec -g $fps -no-scenecut 1 `
-profile:v $vprofile -preset $vpreset -level:v $vlevel -tune:v $vtune `
-b:v "$bitrate" -minrate "$bitrate" -maxrate "$bitrate" -bufsize "$bitrate" `
-r $fps -s "$scale" -an `
"$output"
