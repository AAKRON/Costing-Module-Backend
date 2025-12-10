# 🧪 Security Hardening Testing Guide

## 📋 Prerequisites

1. **Environment Setup**
```bash
# Copy and customize the test environment file
cp .env.test .env
# Edit .env with your actual values
```

2. **Start PostgreSQL**
```bash
# On macOS
brew services start postgresql
# On Windows with Docker
docker run --name postgres -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres:13
```

## 🚀 Phase 1: Basic Application Testing

### Test 1: Docker Ruby 2.7.7 Setup
```bash
# Test Docker and Ruby installation
docker run --rm -v "%cd%:/app" -w /app ruby:2.7.7 ruby -v

# Test bundler installation
docker run --rm -v "%cd%:/app" -w /app ruby:2.7.7 bash -lc "gem install bundler:2.1.4"
```

### Test 2: Dependencies Installation
```bash
# Install gems with Docker
docker run --rm -v "%cd%:/app" -w /app ruby:2.7.7 bash -lc "gem install bundler:2.1.4 && bundle _2.1.4_ install"
```

### Test 3: Database Setup
```bash
# Create and migrate database
bundle exec rake db:create db:migrate RAILS_ENV=development
```

### Test 4: Server Startup
```bash
# Start the application
bundle exec rails server
# Should start on http://localhost:3000
```

## 🔒 Phase 2: Security Features Testing

### Test 5: Health Check Endpoint
```bash
# Test new health endpoint
curl -v http://localhost:3000/health
# Expected: {"status":"ok","timestamp":"...","version":"1.0.0"}
```

### Test 6: Security Headers Validation
```bash
# Check security headers
curl -I http://localhost:3000/health
```

**Expected Headers:**
- `X-Frame-Options: DENY`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000; includeSubdomains`
- `Referrer-Policy: origin-when-cross-origin, strict-origin-when-cross-origin`

### Test 7: JWT Authentication Flow

#### Step 1: Create Test User (Rails Console)
```ruby
# bundle exec rails console
u = User.create(username: 'testuser', password: 'password123', role: 'admin')
```

#### Step 2: Get JWT Token
```bash
curl -X POST http://localhost:3000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"password\":\"password123\"}"
```

**Expected Response:**
```json
{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."}
```

#### Step 3: Use JWT Token
```bash
# Replace YOUR_JWT_TOKEN with the token from step 2
curl -X GET http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Step 4: Test Invalid Token
```bash
curl -X GET http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer invalid_token"
# Expected: 401 Unauthorized
```

### Test 8: Rate Limiting Validation

#### Test Login Rate Limiting
```bash
# Run this multiple times quickly (PowerShell)
for ($i=1; $i -le 12; $i++) {
    curl -X POST http://localhost:3000/api/v1/sessions -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"password\":\"wrongpassword\"}"
    Write-Host "Request $i completed"
}
```

**Expected Result:** After 10 attempts, should get `429 Too Many Requests`

#### Test General Rate Limiting
```bash
# Make many requests quickly
for ($i=1; $i -le 350; $i++) {
    curl http://localhost:3000/health
    if ($i % 50 -eq 0) { Write-Host "Completed $i requests" }
}
```

**Expected Result:** After 300 requests in 5 minutes, should get `429 Too Many Requests`

### Test 9: CORS Validation

#### Test Allowed Origin
```bash
curl -H "Origin: https://uat.aakronline.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: authorization" \
  -X OPTIONS http://localhost:3000/api/v1/items
```

#### Test Blocked Origin
```bash
curl -H "Origin: https://malicious-site.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: authorization" \
  -X OPTIONS http://localhost:3000/api/v1/items
```

**Expected:** Malicious origin should be blocked

### Test 10: Environment Variables Validation

#### Test Hardcoded Secrets Removed
```bash
# Search for hardcoded secrets (should return no results)
grep -r "142f80cc46f6427e99b94baa72e1382c" . --exclude-dir=.git
grep -r "959542c2bd879b4fbe5b68659be359fc731c4d0a" . --exclude-dir=.git
grep -r "Aakron2023$" . --exclude-dir=.git
```

#### Test API Key Protection
```bash
# Test update_type endpoint with wrong API key
curl -X POST "http://localhost:3000/api/v1/items/1/update-type?apikey=wrongkey" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d "item_type=TestType"
# Expected: 401 Not Authorized
```

## 🐳 Phase 3: Docker Testing

### Test 11: Docker Build
```bash
# Build the hardened Docker image
docker build -t costing-api-uat .
```

### Test 12: Docker Security
```bash
# Verify non-root user
docker run --rm costing-api-uat whoami
# Expected: appuser (not root)

# Test health check
docker run --rm -p 3000:3000 costing-api-uat
# Wait for container to start, then:
curl http://localhost:3000/health
```

## 📊 Phase 4: Security Audit

### Test 13: Dependency Audit
```bash
# Run security audit
bundle exec bundler-audit update
bundle exec bundler-audit check
```

### Test 14: Code Quality
```bash
# Run RuboCop
bundle exec rubocop

# Run RSpec tests
bundle exec rspec
```

## 🎯 Success Criteria Checklist

- [ ] Application starts without errors
- [ ] Health endpoint returns 200 OK
- [ ] Security headers are present
- [ ] JWT authentication works
- [ ] Rate limiting triggers after limits
- [ ] CORS blocks unauthorized origins
- [ ] No hardcoded secrets in code
- [ ] Docker builds and runs as non-root
- [ ] Dependency audit passes
- [ ] Tests pass

## 🚨 Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Ensure PostgreSQL is running
   - Check database credentials in .env

2. **JWT Token Issues**
   - Verify SECRET_KEY_BASE is set
   - Check token expiration (60 minutes)

3. **Rate Limiting Not Working**
   - Check Redis connection
   - Verify rack-attack middleware is loaded

4. **Docker Build Fails**
   - Ensure Docker Desktop is running
   - Check file permissions

### Debug Commands
```bash
# Check environment variables are loaded
bundle exec rails console
> ENV['SENTRY_DSN']
> ENV['SECRET_KEY_BASE']

# Check middleware stack
bundle exec rails console
> Rails.application.config.middleware

# Check JWT decoding
bundle exec rails console
> payload = { sub: 1, username: 'test', role: 'admin' }
> token = JwtService.encode(payload)
> JwtService.decode(token)
```

## 🎉 Next Steps After Testing

1. **UAT Deployment**: Deploy to staging environment
2. **Frontend Updates**: Update frontend to use Bearer tokens
3. **Monitoring**: Set up alerts for rate limiting and security headers
4. **Documentation**: Update API documentation with new auth flow