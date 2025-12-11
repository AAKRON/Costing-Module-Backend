# Railway Deployment Guide - Costing Module Backend UAT

## 🚀 Quick Deploy to Railway

### Prerequisites
1. Railway account: https://railway.app
2. GitHub integration enabled
3. This repository pushed to GitHub

### Backend Deployment Steps

#### 1. Create New Project
```bash
# Go to railway.app
# Click "New Project" 
# Select "Deploy from GitHub repo"
# Choose: AAKRON/Costing-Module-Backend-UAT
```

#### 2. Configure Environment Variables
In Railway dashboard, add these environment variables:

**Required Variables:**
```
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
NEW_RELIC_LICENSE_KEY=your_new_relic_license_key_here
SECRET_KEY_BASE=generate_with_rails_secret_command
ITEM_TYPE_UPDATE_APIKEY=your_secure_api_key_here
RAILS_ENV=production
RACK_ENV=production
```

**Database Variables (Railway will auto-provision PostgreSQL):**
```
DATABASE_URL=${{Postgres.DATABASE_URL}}
PGHOST=${{Postgres.PGHOST}}
PGPORT=${{Postgres.PGPORT}}
PGUSER=${{Postgres.PGUSER}}
PGPASSWORD=${{Postgres.PGPASSWORD}}
PGDATABASE=${{Postgres.PGDATABASE}}
```

**Redis Variables (for rate limiting - Railway will auto-provision):**
```
REDIS_URL=${{Redis.REDIS_URL}}
```

#### 3. Add PostgreSQL Database
```bash
# In Railway dashboard:
# Click "New" → "Database" → "Add PostgreSQL"
# Railway will auto-connect DATABASE_URL
```

#### 4. Add Redis (for rate limiting)
```bash
# In Railway dashboard:  
# Click "New" → "Database" → "Add Redis"
# Railway will auto-connect REDIS_URL
```

#### 5. Configure Custom Domain (Optional)
```bash
# In Railway dashboard:
# Go to "Settings" → "Domains"
# Add custom domain like: costing-backend-uat.your-domain.com
# Update CORS origins in backend to include this domain
```

## 🔧 Environment Variables Guide

### Generate SECRET_KEY_BASE
```bash
# Run locally or use online generator:
bundle exec rails secret
# Copy the output to SECRET_KEY_BASE
```

### Sentry Setup (Optional)
```bash
# Go to sentry.io
# Create new project for "Costing Module Backend UAT"
# Copy DSN to SENTRY_DSN
```

### New Relic Setup (Optional) 
```bash
# Go to newrelic.com
# Create account/get license key
# Copy to NEW_RELIC_LICENSE_KEY
```

## 🌐 CORS Configuration

Update the CORS origins in your backend to include Railway URL:

```ruby
# config/initializers/cors.rb
origins 'https://your-railway-backend.up.railway.app',
        'https://your-railway-frontend.up.railway.app', 
        'https://uat.aakronline.com',
        'http://localhost:3000'
```

## ✅ Deployment Verification

After deployment, test these endpoints:

### Health Check
```bash
curl https://your-backend.up.railway.app/health
# Expected: {"status":"ok","timestamp":"...","version":"1.0.0"}
```

### JWT Authentication
```bash
# Create test user via Railway console:
bundle exec rails console
User.create(username: 'testuser', password: 'password123', role: 'admin')

# Test login:
curl -X POST https://your-backend.up.railway.app/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}'
```

### Security Headers
```bash
curl -I https://your-backend.up.railway.app/health
# Should include security headers like X-Frame-Options, etc.
```

## 🔧 Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Verify PostgreSQL service is added
   - Check DATABASE_URL is connected
   - Run migrations: `bundle exec rails db:migrate`

2. **Redis Connection Error**  
   - Add Redis service in Railway
   - Verify REDIS_URL is connected

3. **CORS Errors**
   - Update cors.rb with Railway frontend URL
   - Redeploy after CORS changes

4. **Secret Key Issues**
   - Generate new SECRET_KEY_BASE with `rails secret`
   - Must be different for production

### Railway Console Access
```bash
# In Railway dashboard:
# Go to your service → "Console" tab
# Run: bundle exec rails console
# Create users, check data, debug issues
```

## 📊 Monitoring

Railway provides:
- **Deployment Logs**: See startup and request logs
- **Metrics**: CPU, memory, response times
- **Health Checks**: Automatic monitoring of /health endpoint

## 🎯 Next Steps

1. Deploy backend to Railway
2. Note the Railway backend URL (e.g., `https://xxx.up.railway.app`)  
3. Deploy frontend with backend URL in environment
4. Test end-to-end authentication flow

## 💰 Cost Estimation

Railway pricing:
- **Hobby Plan**: $5/month per service (good for UAT)
- **PostgreSQL**: Included in hobby plan
- **Redis**: Included in hobby plan
- **Custom domains**: Free