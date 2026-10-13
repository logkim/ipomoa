# 공모주 모아(ipomoa) 로컬 즉시 빌드 및 GitHub Pages 배포 스크립트
Write-Host "1. 최신 공모주 데이터 크롤링..." -ForegroundColor Cyan
dart run tool/fetch_ipo_json.dart

Write-Host "`n2. Flutter Web 릴리즈 빌드 (--base-href /ipomoa/)..." -ForegroundColor Cyan
flutter build web --base-href "/ipomoa/" --release

Write-Host "`n3. gh-pages 브랜치로 배포..." -ForegroundColor Cyan
Push-Location build\web
git init
git checkout -B gh-pages
git add -A
git commit -m "Deploy to GitHub Pages ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
git remote add origin https://github.com/logkim/ipomoa.git
git push -f origin gh-pages
Pop-Location

Write-Host "`n배포 완료! 잠시 후 https://logkim.github.io/ipomoa/ 에서 접속 가능합니다." -ForegroundColor Green
