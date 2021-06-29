SELECT DISTINCT ON(t1.name) t1.id, t1.name, 
t4.name AS raw_material_type, 
t3.name AS vendor, t1.cost, t5.name AS unit,
t2.name AS color
FROM raw_materials t1
INNER JOIN colors t2
ON t1.color_id = t2.id 
INNER JOIN vendors t3 
ON t1.vendor_id = t3.id 
INNER JOIN rawmaterialtypes t4 
ON t1.rawmaterialtype_id = t4.id 
INNER JOIN units_of_measures t5 
ON t1.units_of_measure_id = t5.id 
