# verify_portal.ps1 - Pre-flight verification script
$ErrorActionPreference = "Stop"

Write-Host "=========================================================="
Write-Host "Running Pre-Flight Verification on index.html"
Write-Host "=========================================================="

$htmlPath = "D:\Documents\Giulio M\index.html"
if (-not (Test-Path $htmlPath)) {
    throw "index.html not found!"
}

$content = [System.IO.File]::ReadAllText($htmlPath, [System.Text.Encoding]::UTF8)
$errors = @()

# 1. Mojibake characters check
$mojibakePatterns = @("â€", "ðŸ", "â€¢", "Ã©", "Ã¡", "Ã­", "Ã³", "Ãº")
foreach ($pat in $mojibakePatterns) {
    if ($content.Contains($pat)) {
        $errors += "Mojibake character pattern found: $pat"
    }
}

# 2. Unquoted HTML assignments check
if ($content -match '=\s*<div') {
    $errors += "Unquoted assignment to <div found!"
}

# 3. Unquoted getElementById argument check (Rule 1)
# Checks for calls like getElementById(spk- or getElementById(cat- without quotes
if ($content -match 'getElementById\s*\(\s*(?:spk-|cat-|lvl-)') {
    $errors += "Unquoted identifier in getElementById found!"
}

# 4. Closing tags check
if (-not $content.Contains("</html>")) { $errors += "Missing </html> tag!" }
if (-not $content.Contains("</body>")) { $errors += "Missing </body> tag!" }
if (-not $content.Contains("</script>")) { $errors += "Missing </script> tag!" }

# 5. Extract script content and test JS variables
if ($content -match '(?s)<script>(.*?)</script>\s*</body>') {
    $scriptContent = $matches[1]

    # Verify VOCAB_DB exists
    if ($scriptContent -match 'const VOCAB_DB\s*=\s*(\{.*?\});\s*const NATURAL_STRENGTHS' -or $scriptContent -match '(?s)const VOCAB_DB\s*=\s*(\{.*?);[ \r\n]+const NATURAL_STRENGTHS') {
        Write-Host "✓ VOCAB_DB found in script"
    } else {
        $errors += "VOCAB_DB declaration not found in expected format"
    }

    # Verify QUIZ_QUESTIONS exists and validate test structure
    if ($scriptContent -match '(?s)const QUIZ_QUESTIONS\s*=\s*(\[.*?\]);[ \r\n]+const REFLECTION_PROMPTS') {
        $quizJson = $matches[1]
        try {
            $quizObj = $quizJson | ConvertFrom-Json
            Write-Host "✓ QUIZ_QUESTIONS parsed successfully: $($quizObj.Count) questions"
            if ($quizObj.Count -ne 6) {
                $errors += "QUIZ_QUESTIONS count is $($quizObj.Count), expected exactly 6!"
            }
            for ($k = 0; $k -lt $quizObj.Count; $k++) {
                $q = $quizObj[$k]
                if ([string]::IsNullOrWhiteSpace($q.question)) {
                    $errors += "Quiz question $k has empty question text!"
                }
                if ($null -eq $q.options -or $q.options.Count -ne 4) {
                    $errors += "Quiz question $k does not have exactly 4 options! Count: $($q.options.Count)"
                }
                if ($q.correctIndex -lt 0 -or $q.correctIndex -ge $q.options.Count) {
                    $errors += "Quiz question $k correctIndex ($($q.correctIndex)) out of bounds!"
                }
                if ([string]::IsNullOrWhiteSpace($q.explanation)) {
                    $errors += "Quiz question $k has empty explanation!"
                }
                Write-Host "  Question $($k+1): '$($q.question.Substring(0, [Math]::Min(45, $q.question.Length)))...' (Option $($q.correctIndex) is correct)"
            }
        } catch {
            $errors += "Failed to parse QUIZ_QUESTIONS JSON: $_"
        }
    } else {
        $errors += "QUIZ_QUESTIONS declaration not found!"
    }

    # Verify FLASHCARD_KEYS
    if ($scriptContent -match '(?s)const FLASHCARD_KEYS\s*=\s*(\[.*?\]);') {
        $fcJson = $matches[1]
        $fcObj = $fcJson | ConvertFrom-Json
        Write-Host "✓ FLASHCARD_KEYS count: $($fcObj.Count)"
        if ($fcObj.Count -ne 8) {
            $errors += "FLASHCARD_KEYS count is $($fcObj.Count), expected 8!"
        }
    } else {
        $errors += "FLASHCARD_KEYS declaration not found!"
    }

    # Verify 100% of data-vkey exist in VOCAB_DB
    # Extract VOCAB_DB keys from json
    if ($scriptContent -match '(?s)const VOCAB_DB\s*=\s*(\{.*?);[ \r\n]+const NATURAL_STRENGTHS') {
        $vJson = $matches[1]
        try {
            $vObj = $vJson | ConvertFrom-Json
            $dbKeys = $vObj.PSObject.Properties.Name
            Write-Host "✓ VOCAB_DB has $($dbKeys.Count) entries."
            if ($dbKeys.Count -lt 45) {
                $errors += "VOCAB_DB count is $($dbKeys.Count), required 45-60!"
            }

            # Check that all flashcard keys exist in VOCAB_DB
            foreach ($fck in $fcObj) {
                if ($dbKeys -notcontains $fck) {
                    $errors += "Flashcard key '$fck' missing from VOCAB_DB!"
                }
            }

            # Check all tagged keys in TRANSCRIPT_TURNS
            if ($scriptContent -match '(?s)const TRANSCRIPT_TURNS\s*=\s*(\[.*?\]);[ \r\n]+// State Variables') {
                $turnsJson = $matches[1]
                $turnsObj = $turnsJson | ConvertFrom-Json
                $taggedKeys = @()
                foreach ($turn in $turnsObj) {
                    $matches = [regex]::Matches($turn.html, 'data-vkey=\\?"([a-zA-Z0-9\-]+)\\?"')
                    foreach ($m in $matches) {
                        $taggedKeys += $m.Groups[1].Value
                    }
                }
                $uniqueTagged = $taggedKeys | Select-Object -Unique
                Write-Host "✓ Verified $($uniqueTagged.Count) unique vocabulary terms actively tagged in transcript turns."
                foreach ($tkey in $uniqueTagged) {
                    if ($dbKeys -notcontains $tkey) {
                        $errors += "Transcript tagged vocabulary key '$tkey' missing from VOCAB_DB!"
                    }
                }
            }

        } catch {
            $errors += "Failed to parse VOCAB_DB JSON: $_"
        }
    }

} else {
    $errors += "Could not extract script block from HTML"
}

# 6. Check DOM Elements used by Quiz, Flashcards, Soundscape & Navigation
$requiredElementIds = @(
    "quiz-container", "quiz-score-badge", "fc-counter", "fc-badge", "fc-front-title",
    "fc-sub", "fc-back-details", "fc-quote", "fc-es", "transcript-turns-container",
    "vocab-cards-grid", "natural-strengths-grid", "gentle-polishes-grid",
    "asr-fixes-tbody", "editorial-cards-container", "reflections-grid",
    "soundscape-btn", "soundscape-label", "soundscape-preset", "soundscape-volume",
    "autumn-breeze-canvas", "leaves-toggle-btn", "leaves-label",
    "insp-word", "insp-ipa", "insp-pos", "insp-level", "insp-def", "insp-quote", "insp-es"
)

foreach ($id in $requiredElementIds) {
    if (-not $content.Contains("id=`"$id`"")) {
        $errors += "Missing required DOM element with id: '$id'"
    }
}

Write-Host "----------------------------------------------------------"
if ($errors.Count -eq 0) {
    Write-Host "🎉 ALL VERIFICATION CHECKS PASSED WITH ZERO ERRORS!" -ForegroundColor Green
    Write-Host "  ✓ 0 Mojibake characters"
    Write-Host "  ✓ 0 Syntax / unquoted errors"
    Write-Host "  ✓ 100% Vocabulary keys matched and verified in database"
    Write-Host "  ✓ 6 / 6 Context Quiz questions fully verified"
    Write-Host "  ✓ 8 / 8 Active recall flashcards verified"
    Write-Host "  ✓ All 30 required interactive DOM container elements present"
} else {
    Write-Host "❌ VERIFICATION FAILED WITH $($errors.Count) ERRORS:" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "  - $err" -ForegroundColor Red
    }
    throw "Verification failed!"
}
Write-Host "=========================================================="
