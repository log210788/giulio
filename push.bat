@echo off
set "PATH=C:\Program Files\Git\cmd;C:\Users\Administrator\.gemini\antigravity\bin\git\cmd;%PATH%"
cd /d "D:\Documents\Giulio M"
echo ========================================================
echo Pushing Giulio's English Sanctuary to GitHub Pages
echo ========================================================
echo.
git add -A
git commit -m "Update Giulio's English Sanctuary notes for Lesson 01 (Nov 03, 2026)"
git push origin main
git push origin main:gh-pages
echo.
echo ========================================================
echo Done! Both main and gh-pages branches updated on GitHub.
echo ========================================================
pause
