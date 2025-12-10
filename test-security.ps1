# Security Hardening Test Script
# Run this after setting up .env.test file

Write-Host "🧪 COSTING MODULE SECURITY TESTING SCRIPT" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Test 1: Environment Variables
Write-Host "`n📋 Test 1: Environment Variables Check" -ForegroundColor Yellow
if (Test-Path ".env.test") {
    Write-Host "✅ .env.test file found" -ForegroundColor Green
    $envContent = Get-Content ".env.test"
    $requiredVars = @("SENTRY_DSN", "NEW_RELIC_LICENSE_KEY", "SECRET_KEY_BASE", "ITEM_TYPE_UPDATE_APIKEY")
    foreach ($var in $requiredVars) {
        if ($envContent -match "^$var=") {
            Write-Host "✅ $var is configured" -ForegroundColor Green
        } else {
            Write-Host "❌ $var is missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "❌ .env.test file not found. Create it first!" -ForegroundColor Red
    exit 1
}

# Test 2: Docker Ruby 2.7.7 Setup
Write-Host "`n🐳 Test 2: Docker Ruby 2.7.7 & Bundle Install" -ForegroundColor Yellow
try {
    docker run --rm -v "${PWD}:/app" -w /app ruby:2.7.7 bash -lc "ruby -v && gem install bundler:2.1.4 && bundle _2.1.4_ --version"
    Write-Host "✅ Docker Ruby 2.7.7 and Bundler 2.1.4 working" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker setup failed: $_" -ForegroundColor Red
}

# Test 3: Gem Dependencies
Write-Host "`n💎 Test 3: Security Gems Installation" -ForegroundColor Yellow
$securityGems = @("jwt", "rack-attack", "secure_headers", "bundler-audit")
$gemfileContent = Get-Content "Gemfile" -Raw
foreach ($gem in $securityGems) {
    if ($gemfileContent -match "gem ['""]$gem['""]") {
        Write-Host "✅ $gem gem found in Gemfile" -ForegroundColor Green
    } else {
        Write-Host "❌ $gem gem missing from Gemfile" -ForegroundColor Red
    }
}

Write-Host "`n🔧 MANUAL TESTING STEPS:" -ForegroundColor Magenta
Write-Host "1. Start PostgreSQL: brew services start postgresql" -ForegroundColor White
Write-Host "2. Create test database: bundle exec rake db:create db:migrate RAILS_ENV=development" -ForegroundColor White
Write-Host "3. Start server: bundle exec rails server" -ForegroundColor White
Write-Host "4. Run API tests below..." -ForegroundColor White

# Test 4: Create API test commands
Write-Host "`n🌐 API TESTING COMMANDS:" -ForegroundColor Magenta
Write-Host @"
# Test Health Check Endpoint:
curl -v http://localhost:3000/health

# Test Security Headers:
curl -I http://localhost:3000/health

# Test Rate Limiting (run multiple times quickly):
for i in {1..15}; do curl http://localhost:3000/api/v1/sessions -X POST -d "username=test&password=wrong"; done

# Test JWT Authentication:
# 1. First get a JWT token:
curl -X POST http://localhost:3000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"yourpassword"}'

# 2. Use the JWT token:
curl -X GET http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"

# Test CORS (should only allow configured origins):
curl -H "Origin: https://malicious-site.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: authorization" \
  -X OPTIONS http://localhost:3000/api/v1/items
"@ -ForegroundColor White

Write-Host "`n✅ TEST SCRIPT COMPLETED" -ForegroundColor Green