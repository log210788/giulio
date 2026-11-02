# build_portal.ps1 - Generates Giulio M's Peaceful Interactive Lesson Portal
$ErrorActionPreference = "Stop"

Write-Host "Starting build of Giulio's Lesson 01 Interactive Portal..."

# 1. Read Raw Transcript
$transcriptPath = "D:\Documents\Giulio M\Transcripts\11-03-2026.txt"
if (-not (Test-Path $transcriptPath)) {
    throw "Transcript file not found at: $transcriptPath"
}
$rawLines = Get-Content $transcriptPath -Encoding UTF8

# Parse Speaking Turns
$turns = @()
$currentSpeaker = ""
$currentTime = ""
$currentLines = @()

foreach ($line in $rawLines) {
    if ($line -match '^([A-Za-z0-9''\s]+)\s*\|\s*(\d?\d:\d\d(?::\d\d)?)') {
        if ($currentSpeaker -ne "") {
            $turns += [PSCustomObject]@{
                speaker = $currentSpeaker.Trim()
                time = $currentTime.Trim()
                text = ($currentLines -join " ").Trim()
            }
        }
        $currentSpeaker = $matches[1]
        $currentTime = $matches[2]
        $currentLines = @()
    } else {
        if ($line.Trim() -ne "") {
            $currentLines += $line.Trim()
        }
    }
}
if ($currentSpeaker -ne "") {
    $turns += [PSCustomObject]@{
        speaker = $currentSpeaker.Trim()
        time = $currentTime.Trim()
        text = ($currentLines -join " ").Trim()
    }
}

Write-Host "Loaded $($turns.Count) speaking turns from transcript."
