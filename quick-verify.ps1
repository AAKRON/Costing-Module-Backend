Write-Host "🔍 QUICK SECURITY IMPLEMENTATION VERIFICATION" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "`n1. ✅ Checking Security Files Created..." -ForegroundColor Yellow
$securityFiles = @(
    "app/services/jwt_service.rb",
    "app/services/filename_sanitizer.rb", 
    "app/validators/file_upload_validator.rb",
    "config/initializers/rack_attack.rb",
    "config/initializers/secure_headers.rb",
    "app/controllers/health_controller.rb",
    ".env.test"
)

foreach ($file in $securityFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file" -ForegroundColor Red
    }
}

Write-Host "`n2. ✅ Checking Gemfile Security Gems..." -ForegroundColor Yellow
$gemfile = Get-Content "Gemfile" -Raw
$securityGems = @("jwt", "rack-attack", "secure_headers", "bundler-audit")
foreach ($gem in $securityGems) {
    if ($gemfile -match "gem.*$gem") {
        Write-Host "  ✅ $gem gem added" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $gem gem missing" -ForegroundColor Red
    }
}

Write-Host "`n3. ✅ Checking Hardcoded Secrets Removed..." -ForegroundColor Yellow
$files = @("config/initializers/sentry.rb", "config/newrelic.yml", "config/secrets.yml")
$foundSecrets = $false
foreach ($file in $files) {
    $content = Get-Content $file -Raw
    if ($content -match "142f80cc46f6427e99b94baa72e1382c|959542c2bd879b4fbe5b68659be359fc731c4d0a|ff82b771e914a1851f") {
        Write-Host "  ❌ Hardcoded secret found in $file" -ForegroundColor Red
        $foundSecrets = $true
    }
}
if (-not $foundSecrets) {
    Write-Host "  ✅ No hardcoded secrets found" -ForegroundColor Green
}

Write-Host "`n4. ✅ Checking Environment Variables Setup..." -ForegroundColor Yellow
if (Test-Path ".env.test") {
    Write-Host "  ✅ .env.test created" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  .env.test not found - copy from .env.test and customize" -ForegroundColor Yellow
}

Write-Host "`n5. ✅ Docker Ruby 2.7.7 Availability..." -ForegroundColor Yellow
try {
    $dockerResult = docker run --rm ruby:2.7.7 ruby -v 2>&1
    if ($dockerResult -match "ruby 2.7.7") {
        Write-Host "  ✅ Ruby 2.7.7 Docker image available" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Ruby 2.7.7 Docker image not available" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Docker not available or not running" -ForegroundColor Red
}

Write-Host "`n🎯 NEXT STEPS:" -ForegroundColor Magenta
Write-Host "1. Copy .env.test to .env and customize with your values" -ForegroundColor White
Write-Host "2. Ensure PostgreSQL is running" -ForegroundColor White  
Write-Host "3. Follow TESTING_GUIDE.md for comprehensive testing" -ForegroundColor White
Write-Host "4. Start with: bundle install && bundle exec rails server" -ForegroundColor White

Write-Host "`n✅ VERIFICATION COMPLETE!" -ForegroundColor Green