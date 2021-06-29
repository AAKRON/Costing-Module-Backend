SELECT DISTINCT ON (t1.blank_number) t1.id, t1.blank_number, 
				t1.description, t2.description AS blank_type,
                t1.cost
FROM blanks t1
LEFT JOIN blank_types t2 
ON t1.blank_type_id = t2.type_number
