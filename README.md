# Costing-module-api

The API service for the costing module

### 1. Install dependencies (On MacOS)

1. Install postgreSQL with `brew install postgresql`
2. Install dependencies with `sudo bundle install`

### 2. Migrate and seed the test db

1. We recommend to install PGAdmin: https://www.postgresql.org/ftp/pgadmin/pgadmin4/v7.1/macos/
2. If you are setting up postgresql for first time, you must register the postres user with the next command: `createuser postgres -s` and create a local server.
3. Create a DB named `costing_development_db`
4. Run migrations: `rails db:migrate`
5. Seed the database with: `rake db:seed`

### 3. Run Ruby

1. Start Postgresql with `brew services start postgresql`, verify that it is running with the following command: `brew services list`

2. Run ruby with: `rails server`

### 4. Create Test User

1. Run the rails console with: `rails console`
2. To create a test user, run the following command:
   `u = User.create(username: 'test', role:'admin')`
