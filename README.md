# Costing-module-api

The API service for the costing module

### 1. Install dependencies (On MacOS)

1. Install postgreSQL with `brew install postgresql`
1. Install postgreSQL with `brew install redis`
2. Install dependencies with `sudo bundle install`

### 2. Migrate and seed the test db

1. We recommend to install PGAdmin: https://www.postgresql.org/ftp/pgadmin/pgadmin4/v7.1/macos/
2. If you are setting up postgresql for first time, you must register the postres user with the next command: `createuser postgres -s` and create a local server.
3. Create a DB named `costing_development_db`
4. Run migrations: `rake db:migrate`
5. Seed the database with: `rake db:seed`
6. If you want to reseed your DB, run the following commands: `rake db:schema:load` and run `rake db:seed`.

### 3. Run Ruby

1. Start Postgresql with `brew services start postgresql`, verify that it is running with the following command: `brew services list`

2. Run ruby with: `rails server`

### 4. Create Test User (Only if needed)

1. Run the rails console with: `rails console`
2. To create a test user, run the following command: `u = User.create(username: 'test', role:'admin')`

### 5. OPTIONAL - Build and run docker

1. Build docker image with: `docker build -t aakron_api .` (Only one time)
2. To run a container from our image: `docker-compose up`
3. To run the container bash run: `docker-compose exec aakron_api bash`

