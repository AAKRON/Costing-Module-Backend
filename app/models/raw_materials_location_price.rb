class RawMaterialsLocationPrice < ApplicationRecord
    has_one :raw_materials
    has_one :locations
end
