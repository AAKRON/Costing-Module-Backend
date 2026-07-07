# Costing Module API

Rails API backend for the Costing Module. Deployed on Railway.

---

## Local development setup (macOS)

1. Install dependencies: `brew install postgresql redis`
2. Install gems: `sudo bundle install`
3. Create a local DB named `costing_development_db`
4. Run migrations: `rake db:migrate`
5. Seed: `rake db:seed`
6. Start services: `brew services start postgresql && brew services start redis`
7. Start the server: `rails server`

To reset and reseed: `rake db:schema:load && rake db:seed`

**Create a test user (if needed):**
```
rails console
User.create(username: 'test', role: 'admin')
```

**Docker (optional):**
```
docker build -t aakron_api .
docker-compose up
```

---

## Railway deployment

### Required environment variables

| Variable | Description |
|----------|-------------|
| `SECRET_KEY_BASE` | Rails secret key |
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string (Sidekiq) |
| `RAILS_ENV` | Set to `production` |
| `RACK_ENV` | Set to `production` |
| `ITEM_TYPE_UPDATE_APIKEY` | API key for the item-type bulk update endpoint |
| `TIORY_COST_APIKEY` | API key for the ERP cost-sync endpoint (see below) |
| `SIDEKIQ_PASSWORD` | Password for the Sidekiq web UI at `/sidekiq` |

### Deploy branch

`main` — Railway auto-deploys on push.

---

## API endpoints

### Authentication

Most endpoints require JWT authentication:
```
Authorization: Bearer <token>
Database: <year>   # e.g. 2026 — routes the request to costing_database_2026
```

Get a token via `POST /api/v2/auth/login`.

### ERP cost-sync endpoint (no JWT required)

```
GET /api/v1/item-cost/:item_number?apikey=TIORY_COST_APIKEY
Header: Database: <year>
```

Returns `total_price_cost` from the `ItemCostView` for the given item and year database.
Used by the Tiory ERP Item Pricing screen to auto-fill cost when the arrow button is pressed.
Protected by the `TIORY_COST_APIKEY` env var (not JWT) so the ERP server can call it without
a user session.

**Response (found):**
```json
{
  "found": true,
  "item_number": "00001",
  "description": "Widget",
  "total_price_cost": 1.23456
}
```

**Response (not found):**
```json
{ "found": false, "item_number": "00001" }
```

**Response (wrong API key):**
```json
{ "message": "Not Authorized" }  // HTTP 401
```

---

## Health check

```
GET /health
```

Returns app status, user count, and current database info. Used by Railway healthcheck.
