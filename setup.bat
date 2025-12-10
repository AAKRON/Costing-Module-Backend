@echo off
echo 🚀 Setting up Costing Module Backend for Testing
echo ================================================

echo.
echo 📋 Step 1: Create .env file from template
if exist .env (
    echo ✅ .env file already exists
) else (
    copy .env.test .env
    echo ✅ Created .env file from template
)

echo.
echo 📝 Step 2: You need to customize these values in .env:
echo.
echo Required Environment Variables:
echo   SENTRY_DSN=https://your-real-sentry-dsn@sentry.io/project-id
echo   NEW_RELIC_LICENSE_KEY=your_real_new_relic_license_key
echo   SECRET_KEY_BASE=generate_a_long_random_string_here
echo   ITEM_TYPE_UPDATE_APIKEY=your_secure_api_key_here
echo.

echo 🔧 Step 3: Generate a secret key base
echo Run this command to generate a secure secret:
echo   bundle exec rails secret
echo.

echo 💾 Step 4: Database setup (if PostgreSQL is running)
echo   bundle install
echo   bundle exec rake db:create db:migrate RAILS_ENV=development
echo.

echo 🎯 Step 5: Test the application
echo   bundle exec rails server
echo   curl http://localhost:3000/health
echo.

echo ✅ Setup script completed!
echo Edit .env file with your real values before starting the server.
pause