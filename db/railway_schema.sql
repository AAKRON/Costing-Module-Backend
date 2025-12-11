-- Railway UAT Database Schema
-- Generated from db/schema.rb for direct import

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "plpgsql";

-- App Constants
CREATE TABLE "app_constants" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR,
  "value" VARCHAR,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Blank Jobs  
CREATE TABLE "blank_jobs" (
  "id" SERIAL PRIMARY KEY,
  "hour_per_piece" DECIMAL,
  "blank_id" INTEGER,
  "job_listing_id" INTEGER,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL,
  "cell_key" VARCHAR
);

-- Blank Raw Materials
CREATE TABLE "blank_raw_materials" (
  "id" SERIAL PRIMARY KEY,
  "piece_per_unit_of_measure" INTEGER,
  "cost" DECIMAL,
  "blank_id" INTEGER,
  "raw_material_id" INTEGER,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);
CREATE INDEX "index_blank_raw_materials_on_blank_id" ON "blank_raw_materials" ("blank_id");
CREATE INDEX "index_blank_raw_materials_on_raw_material_id" ON "blank_raw_materials" ("raw_material_id");

-- Blank Types
CREATE TABLE "blank_types" (
  "id" SERIAL PRIMARY KEY,
  "type_number" INTEGER NOT NULL,
  "description" VARCHAR NOT NULL,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);
CREATE INDEX "index_blank_types_on_type_number" ON "blank_types" ("type_number");

-- Blanks
CREATE TABLE "blanks" (
  "id" INTEGER PRIMARY KEY,
  "blank_number" INTEGER,
  "description" VARCHAR,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Boxes
CREATE TABLE "boxes" (
  "id" SERIAL PRIMARY KEY,
  "length" DECIMAL,
  "width" DECIMAL,
  "height" DECIMAL,
  "cost_per_box" DECIMAL,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Colors
CREATE TABLE "colors" (
  "id" SERIAL PRIMARY KEY,
  "description" VARCHAR,
  "cost_per_unit" DECIMAL,
  "percentage_used" DECIMAL,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Item Jobs
CREATE TABLE "item_jobs" (
  "id" SERIAL PRIMARY KEY,
  "hour_per_piece" DECIMAL,
  "item_id" INTEGER,
  "job_listing_id" INTEGER,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL,
  "cell_key" VARCHAR
);

-- Items
CREATE TABLE "items" (
  "id" INTEGER PRIMARY KEY,
  "item_number" INTEGER,
  "description" VARCHAR,
  "box_id" INTEGER,
  "number_of_pcs_per_box" INTEGER,
  "ink_cost" DECIMAL,
  "item_type_id" INTEGER,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Item Types
CREATE TABLE "item_types" (
  "id" SERIAL PRIMARY KEY,
  "type_number" INTEGER NOT NULL,
  "description" VARCHAR NOT NULL,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);
CREATE INDEX "index_item_types_on_type_number" ON "item_types" ("type_number");

-- Job Listings
CREATE TABLE "job_listings" (
  "id" INTEGER PRIMARY KEY,
  "description" VARCHAR,
  "wages_per_hour" DECIMAL,
  "screen_id" INTEGER,
  "job_number" INTEGER,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Raw Materials
CREATE TABLE "raw_materials" (
  "id" SERIAL PRIMARY KEY,
  "description" VARCHAR,
  "cost_per_unit_of_measure" DECIMAL,
  "units_of_measure_id" INTEGER,
  "rawmaterialtype_id" INTEGER,
  "vendor_id" INTEGER,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Raw Material Types
CREATE TABLE "rawmaterialtypes" (
  "id" SERIAL PRIMARY KEY,
  "type" VARCHAR,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Screens
CREATE TABLE "screens" (
  "id" SERIAL PRIMARY KEY,
  "screen_size" VARCHAR,
  "cost_per_screen" DECIMAL,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Units of Measure
CREATE TABLE "units_of_measures" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR,
  "abbr" VARCHAR,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Users
CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR,
  "password_digest" VARCHAR,
  "role" VARCHAR,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Vendors
CREATE TABLE "vendors" (
  "id" SERIAL PRIMARY KEY,
  "vendor_name" VARCHAR,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);

-- Schema Migrations (Rails tracking)
CREATE TABLE "schema_migrations" (
  "version" VARCHAR NOT NULL
);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");

-- Add the latest migration version
INSERT INTO "schema_migrations" ("version") VALUES ('2017_11_07_111207');

-- AR Internal Metadata
CREATE TABLE "ar_internal_metadata" (
  "key" VARCHAR NOT NULL,
  "value" VARCHAR,
  "created_at" TIMESTAMP NOT NULL,
  "updated_at" TIMESTAMP NOT NULL
);
CREATE UNIQUE INDEX "unique_ar_internal_metadata" ON "ar_internal_metadata" ("key");

-- Insert Rails environment info
INSERT INTO "ar_internal_metadata" ("key", "value", "created_at", "updated_at") 
VALUES ('environment', 'production', NOW(), NOW());