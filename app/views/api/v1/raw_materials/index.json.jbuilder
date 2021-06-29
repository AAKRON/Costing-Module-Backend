# frozen_string_literal: true
json.array! @raw_materials do |record|
  json.id record.id
  json.name record.name
  json.raw_material_type record.raw_material_type
  json.vendor record.vendor
  json.cost record.cost
  json.unit record.unit
  json.color record.color
end
