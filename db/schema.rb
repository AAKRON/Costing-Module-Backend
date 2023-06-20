# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2017_11_07_111207) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_constants", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blank_jobs", id: :serial, force: :cascade do |t|
    t.decimal "hour_per_piece"
    t.integer "blank_id"
    t.integer "job_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cell_key"
  end

  create_table "blank_raw_materials", id: :serial, force: :cascade do |t|
    t.integer "piece_per_unit_of_measure"
    t.decimal "cost"
    t.integer "blank_id"
    t.integer "raw_material_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blank_id"], name: "index_blank_raw_materials_on_blank_id"
    t.index ["raw_material_id"], name: "index_blank_raw_materials_on_raw_material_id"
  end

  create_table "blank_types", id: :serial, force: :cascade do |t|
    t.integer "type_number", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type_number"], name: "index_blank_types_on_type_number"
  end

  create_table "blanks", id: :serial, force: :cascade do |t|
    t.string "description"
    t.integer "blank_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "blank_type_id", default: 0
    t.decimal "cost", precision: 8, scale: 3, default: "0.0"
  end

  create_table "blanks_listing_by_items", id: :serial, force: :cascade do |t|
    t.integer "item_number"
    t.integer "blank_number"
    t.integer "mult"
    t.integer "div"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cell_key"
  end

  create_table "blanks_listing_item_with_costs", id: :serial, force: :cascade do |t|
    t.integer "item_number"
    t.integer "blank_number"
    t.float "cost_per_blank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cell_key"
  end

  create_table "boxes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.decimal "cost_per_box"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "colorant_costs", id: :serial, force: :cascade do |t|
    t.decimal "colorant_percentage"
    t.decimal "cost"
    t.integer "blank_id"
    t.integer "colorant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blank_id"], name: "index_colorant_costs_on_blank_id"
    t.index ["colorant_id"], name: "index_colorant_costs_on_colorant_id"
  end

  create_table "colorants", id: :serial, force: :cascade do |t|
    t.string "description"
    t.string "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "colors", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "cost_of_color"
    t.index ["name"], name: "index_colors_on_name", unique: true
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.string "content_type"
    t.binary "file_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_type"
  end

  create_table "final_calculations", id: :serial, force: :cascade do |t|
    t.integer "blank_id"
    t.integer "color_number"
    t.string "color_description"
    t.integer "raw_material_id"
    t.string "colorant_one"
    t.integer "number_of_pieces_per_unit_one"
    t.float "percentage_of_colorant_one"
    t.string "colorant_two"
    t.integer "number_of_pieces_per_unit_two"
    t.float "percentage_of_colorant_two"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cell_key"
    t.index ["blank_id"], name: "index_final_calculations_on_blank_id"
  end

  create_table "item_blank_job_pieces", id: :serial, force: :cascade do |t|
    t.decimal "hour_per_piece"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "blank_id"
    t.integer "item_job_id"
  end

  create_table "item_boxes", id: :serial, force: :cascade do |t|
    t.integer "pieces_per_box"
    t.integer "box_id"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["box_id"], name: "index_item_boxes_on_box_id"
    t.index ["item_id"], name: "index_item_boxes_on_item_id"
  end

  create_table "item_jobs", id: :serial, force: :cascade do |t|
    t.decimal "hour_per_piece"
    t.integer "item_id"
    t.integer "job_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cell_key"
    t.index ["item_id"], name: "index_item_jobs_on_item_id"
    t.index ["job_listing_id"], name: "index_item_jobs_on_job_listing_id"
  end

  create_table "item_jobs_pieces", id: :serial, force: :cascade do |t|
    t.decimal "hour_per_piece"
    t.integer "blank_id"
    t.integer "item_job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blank_id"], name: "index_item_jobs_pieces_on_blank_id"
    t.index ["item_job_id"], name: "index_item_jobs_pieces_on_item_job_id"
  end

  create_table "item_types", id: :serial, force: :cascade do |t|
    t.integer "type_number", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type_number"], name: "index_item_types_on_type_number"
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.integer "item_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.integer "box_id", default: 0
    t.integer "number_of_pcs_per_box", default: 0
    t.decimal "ink_cost", default: "0.0"
    t.integer "item_type_id", default: 0
    t.index ["item_number"], name: "index_items_on_item_number", unique: true
  end

  create_table "job_listings", id: :serial, force: :cascade do |t|
    t.string "description"
    t.float "wages_per_hour"
    t.integer "screen_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "job_number"
    t.index ["screen_id"], name: "index_job_listings_on_screen_id"
  end

  create_table "material_costs", id: :serial, force: :cascade do |t|
    t.decimal "ink_cost"
    t.decimal "box_cost_per_item"
    t.decimal "screen_size_cost"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_material_costs_on_item_id"
  end

  create_table "overhead_costs", id: :serial, force: :cascade do |t|
    t.decimal "cost"
    t.integer "overhead_percentage_id"
    t.integer "job_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_listing_id"], name: "index_overhead_costs_on_job_listing_id"
    t.index ["overhead_percentage_id"], name: "index_overhead_costs_on_overhead_percentage_id"
  end

  create_table "overhead_percentages", id: :serial, force: :cascade do |t|
    t.integer "type"
    t.integer "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "raw_materials", id: :serial, force: :cascade do |t|
    t.string "name"
    t.float "cost"
    t.integer "units_of_measure_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "color_id"
    t.integer "vendor_id"
    t.integer "rawmaterialtype_id"
  end

  create_table "rawmaterialtypes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_rawmaterialtypes_on_name", unique: true
  end

  create_table "screen_sizes", id: :serial, force: :cascade do |t|
    t.string "size"
    t.decimal "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "screens", id: :serial, force: :cascade do |t|
    t.string "screen_size"
    t.float "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "unitofmeasures", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units_of_measures", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_units_of_measures_on_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username"
    t.string "token"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

  create_table "vendors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_vendors_on_name", unique: true
  end


  create_view "item_with_job_counts", sql_definition: <<-SQL
      SELECT i.id,
      i.item_number,
      i.description,
      count(ij.item_id) AS number_of_jobs
     FROM (items i
       LEFT JOIN item_jobs ij ON ((ij.item_id = i.id)))
    GROUP BY i.id;
  SQL
  create_view "raw_material_views", sql_definition: <<-SQL
      SELECT DISTINCT ON (t1.name) t1.id,
      t1.name,
      t4.name AS raw_material_type,
      t3.name AS vendor,
      t1.cost,
      t5.name AS unit,
      t2.name AS color
     FROM ((((raw_materials t1
       JOIN colors t2 ON ((t1.color_id = t2.id)))
       JOIN vendors t3 ON ((t1.vendor_id = t3.id)))
       JOIN rawmaterialtypes t4 ON ((t1.rawmaterialtype_id = t4.id)))
       JOIN units_of_measures t5 ON ((t1.units_of_measure_id = t5.id)));
  SQL
  create_view "final_calculation_views", sql_definition: <<-SQL
      SELECT fc.id,
      fc.blank_id,
      rm.name AS raw_material_name,
      fc.color_description,
      rm.cost AS raw_material_cost,
      COALESCE(c1.cost_of_color, (0)::double precision) AS cost_of_color_one,
      COALESCE(c2.cost_of_color, (0)::double precision) AS cost_of_color_two,
      COALESCE(fc.percentage_of_colorant_one, (0)::double precision) AS percentage_of_colorant_one,
      COALESCE(fc.percentage_of_colorant_two, (0)::double precision) AS percentage_of_colorant_two,
      fc.number_of_pieces_per_unit_one,
      fc.number_of_pieces_per_unit_two
     FROM (((final_calculations fc
       LEFT JOIN colors c1 ON (((c1.name)::text = (fc.colorant_one)::text)))
       LEFT JOIN colors c2 ON (((c2.name)::text = (fc.colorant_two)::text)))
       LEFT JOIN raw_materials rm ON ((rm.id = fc.raw_material_id)));
  SQL
  create_view "job_with_screen_listings", sql_definition: <<-SQL
      SELECT jl.id,
      jl.description,
      jl.job_number,
      s.screen_size,
      jl.screen_id,
      jl.wages_per_hour
     FROM (job_listings jl
       LEFT JOIN screens s ON ((s.id = jl.screen_id)));
  SQL
  create_view "item_with_box_costs", sql_definition: <<-SQL
      SELECT t1.id,
      t1.item_number,
      t1.description,
      t2.name AS box_name,
      t1.number_of_pcs_per_box,
      (t1.ink_cost)::numeric(10,4) AS ink_cost,
      (t2.cost_per_box / (t1.number_of_pcs_per_box)::numeric) AS box_cost
     FROM (items t1
       LEFT JOIN boxes t2 ON ((t1.box_id = t2.id)));
  SQL
  create_view "blank_views", sql_definition: <<-SQL
      SELECT DISTINCT ON (t1.blank_number) t1.id,
      t2.id AS blank_type_id,
      t2.type_number,
      t1.blank_number,
      t1.description,
      t2.description AS blank_type,
      t1.cost
     FROM (blanks t1
       LEFT JOIN blank_types t2 ON ((t1.blank_type_id = t2.type_number)));
  SQL
  create_view "blank_job_views", sql_definition: <<-SQL
      SELECT t1.id,
      t1.blank_number,
      t1.description,
      count(t2.blank_id) AS number_of_jobs
     FROM (blanks t1
       LEFT JOIN blank_jobs t2 ON ((t1.blank_number = t2.blank_id)))
    GROUP BY t1.id, t1.blank_number, t1.description;
  SQL
  create_view "blank_average_costs", sql_definition: <<-SQL
      SELECT final_calculation_views.blank_id,
      (avg((((COALESCE(final_calculation_views.raw_material_cost, (0)::double precision) / (final_calculation_views.number_of_pieces_per_unit_one)::double precision) + ((COALESCE(final_calculation_views.cost_of_color_one, (0)::double precision) * COALESCE(final_calculation_views.percentage_of_colorant_one, (0)::double precision)) / (final_calculation_views.number_of_pieces_per_unit_one)::double precision)) + ((COALESCE(final_calculation_views.cost_of_color_two, (0)::double precision) * COALESCE(final_calculation_views.percentage_of_colorant_two, (0)::double precision)) / (final_calculation_views.number_of_pieces_per_unit_two)::double precision))))::numeric(10,5) AS average_cost_of_blank
     FROM final_calculation_views
    GROUP BY final_calculation_views.blank_id;
  SQL
  create_view "blank_cost_views", sql_definition: <<-SQL
      SELECT DISTINCT ON (b.blank_number) b.id,
      b.blank_number,
      b.description,
      (b.cost)::numeric(10,5) AS cost,
      bt.id AS blank_type_id,
      bt.type_number,
      bt.description AS blank_type,
      COALESCE(((bc.cost_for_price + (COALESCE(bac.average_cost_of_blank, (0)::numeric))::double precision))::numeric(10,5), (0)::numeric) AS total_blank_cost_for_price,
      COALESCE(((bc.cost_for_inventory + (COALESCE(bac.average_cost_of_blank, (0)::numeric))::double precision))::numeric(10,5), (0)::numeric) AS total_blank_cost_for_inventory
     FROM (((( SELECT bj.blank_id,
              sum(((jl.wages_per_hour * (bj.hour_per_piece)::double precision) + ((jl.wages_per_hour * (bj.hour_per_piece)::double precision) * ((acpo.value)::numeric)::double precision))) AS cost_for_price,
              sum(((jl.wages_per_hour * (bj.hour_per_piece)::double precision) + ((jl.wages_per_hour * (bj.hour_per_piece)::double precision) * ((acio.value)::numeric)::double precision))) AS cost_for_inventory
             FROM (((blank_jobs bj
               LEFT JOIN job_listings jl ON ((jl.id = bj.job_listing_id)))
               LEFT JOIN app_constants acpo ON (((acpo.name)::text = 'price_overhead_percentage'::text)))
               LEFT JOIN app_constants acio ON (((acio.name)::text = 'inventory_overhead_percentage'::text)))
            GROUP BY bj.blank_id) bc
       LEFT JOIN blank_average_costs bac ON ((bac.blank_id = bc.blank_id)))
       RIGHT JOIN blanks b ON ((b.id = bc.blank_id)))
       LEFT JOIN blank_types bt ON ((b.blank_type_id = bt.type_number)));
  SQL
  create_view "item_with_blank_per_cost_views", sql_definition: <<-SQL
      SELECT bliwc.id,
      bliwc.item_number,
      bliwc.blank_number,
      (((bcv.cost * (COALESCE(blbi.mult, 1))::numeric) / (COALESCE(blbi.div, 1))::numeric))::numeric(10,5) AS cost,
          CASE
              WHEN (bcv.type_number = 1) THEN (((bcv.total_blank_cost_for_price * (COALESCE(blbi.mult, 1))::numeric) / (COALESCE(blbi.div, 1))::numeric))::numeric(10,5)
              ELSE (0)::numeric
          END AS total_blank_cost_for_price,
          CASE
              WHEN (bcv.type_number = 1) THEN (((bcv.total_blank_cost_for_inventory * (COALESCE(blbi.mult, 1))::numeric) / (COALESCE(blbi.div, 1))::numeric))::numeric(10,5)
              ELSE (0)::numeric
          END AS total_blank_cost_for_inventory
     FROM ((blanks_listing_item_with_costs bliwc
       LEFT JOIN blank_cost_views bcv ON ((bcv.id = bliwc.blank_number)))
       LEFT JOIN blanks_listing_by_items blbi ON (((blbi.item_number = bliwc.item_number) AND (blbi.blank_number = bliwc.blank_number))));
  SQL
  create_view "item_cost_views", sql_definition: <<-SQL
      SELECT i.id,
      i.item_number,
      i.description,
      it.description AS type_description,
      i.item_type_id,
      b.name AS box_name,
      i.number_of_pcs_per_box,
      (i.ink_cost)::numeric(10,5) AS ink_cost,
      ((COALESCE(b.cost_per_box, (0)::numeric) / (
          CASE
              WHEN (i.number_of_pcs_per_box = 0) THEN 1
              ELSE i.number_of_pcs_per_box
          END)::numeric))::numeric(10,5) AS box_cost,
      ((((((COALESCE(ibc.item_blank_cost_for_price, (0)::numeric) + COALESCE(ijcws.cost_for_price, (0)::numeric)) + ((COALESCE(b.cost_per_box, (0)::numeric) / (
          CASE
              WHEN (i.number_of_pcs_per_box = 0) THEN 1
              ELSE i.number_of_pcs_per_box
          END)::numeric))::numeric(10,5)))::double precision + COALESCE(ijcws.screen_cost, (0)::double precision)) + (i.ink_cost)::double precision))::numeric(10,5) AS total_price_cost,
      ((((((COALESCE(ibc.item_blank_cost_for_inventory, (0)::numeric) + COALESCE(ijcws.cost_for_inventory, (0)::numeric)) + ((COALESCE(b.cost_per_box, (0)::numeric) / (
          CASE
              WHEN (i.number_of_pcs_per_box = 0) THEN 1
              ELSE i.number_of_pcs_per_box
          END)::numeric))::numeric(10,5)))::double precision + COALESCE(ijcws.screen_cost, (0)::double precision)) + (i.ink_cost)::double precision))::numeric(10,5) AS total_inventory_cost
     FROM ((((items i
       LEFT JOIN boxes b ON ((i.box_id = b.id)))
       LEFT JOIN ( SELECT iwbpcv.item_number,
              sum((iwbpcv.cost + iwbpcv.total_blank_cost_for_price)) AS item_blank_cost_for_price,
              sum((iwbpcv.cost + iwbpcv.total_blank_cost_for_inventory)) AS item_blank_cost_for_inventory
             FROM item_with_blank_per_cost_views iwbpcv
            GROUP BY iwbpcv.item_number) ibc ON ((ibc.item_number = i.id)))
       LEFT JOIN ( SELECT ij.item_id,
              sum(((((jl.wages_per_hour * ((ij.hour_per_piece)::numeric(10,5))::double precision))::numeric(10,5) + (((jl.wages_per_hour * ((ij.hour_per_piece)::numeric(10,5))::double precision))::numeric(10,5) * (acpo.value)::numeric)))::numeric(10,5)) AS cost_for_price,
              sum(((((jl.wages_per_hour * ((ij.hour_per_piece)::numeric(10,5))::double precision))::numeric(10,5) + (((jl.wages_per_hour * ((ij.hour_per_piece)::numeric(10,5))::double precision))::numeric(10,5) * (acio.value)::numeric)))::numeric(10,5)) AS cost_for_inventory,
              sum(COALESCE(s.cost, (0)::double precision)) AS screen_cost
             FROM ((((item_jobs ij
               LEFT JOIN job_listings jl ON ((jl.id = ij.job_listing_id)))
               LEFT JOIN screens s ON ((s.id = jl.screen_id)))
               LEFT JOIN app_constants acpo ON (((acpo.name)::text = 'price_overhead_percentage'::text)))
               LEFT JOIN app_constants acio ON (((acio.name)::text = 'inventory_overhead_percentage'::text)))
            GROUP BY ij.item_id) ijcws ON ((ijcws.item_id = i.id)))
       LEFT JOIN item_types it ON ((it.type_number = i.item_type_id)));
  SQL
  create_view "blank_final_calculations_views", sql_definition: <<-SQL
      SELECT fc.id,
      fc.blank_id AS blank_number,
      b.description AS blank_name,
      rm.name AS raw_material,
      fc.color_description,
      ((COALESCE(rm.cost, (0)::double precision) / (fc.number_of_pieces_per_unit_one)::double precision))::numeric(10,5) AS raw_calculated,
      (((((COALESCE(c1.cost_of_color, (0)::double precision) * COALESCE(fc.percentage_of_colorant_one, (0)::double precision)) / (fc.number_of_pieces_per_unit_one)::double precision))::numeric(10,5) + (((COALESCE(c2.cost_of_color, (0)::double precision) * COALESCE(fc.percentage_of_colorant_two, (0)::double precision)) / (COALESCE(fc.number_of_pieces_per_unit_two, 1))::double precision))::numeric(10,5)))::numeric(10,5) AS cost_of_colorant_or_lacquer,
      ((((COALESCE(rm.cost, (0)::double precision) / (fc.number_of_pieces_per_unit_one)::double precision))::numeric(10,5) + ((((COALESCE(c1.cost_of_color, (0)::double precision) * COALESCE(fc.percentage_of_colorant_one, (0)::double precision)) / (fc.number_of_pieces_per_unit_one)::double precision) + ((COALESCE(c2.cost_of_color, (0)::double precision) * COALESCE(fc.percentage_of_colorant_two, (0)::double precision)) / (COALESCE(fc.number_of_pieces_per_unit_two, 1))::double precision)))::numeric(10,5)))::numeric(10,5) AS total,
      bac.average_cost_of_blank AS ave_cost
     FROM (((((final_calculations fc
       LEFT JOIN colors c1 ON (((c1.name)::text = (fc.colorant_one)::text)))
       LEFT JOIN colors c2 ON (((c2.name)::text = (fc.colorant_two)::text)))
       LEFT JOIN raw_materials rm ON ((rm.id = fc.raw_material_id)))
       LEFT JOIN blanks b ON ((b.id = fc.blank_id)))
       LEFT JOIN blank_average_costs bac ON ((bac.blank_id = fc.blank_id)));
  SQL
end
