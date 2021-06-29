select t1.id, t1.item_number,  t1.description, t2.name as box_name, t1.number_of_pcs_per_box,
		CAST(t1.ink_cost AS DECIMAL(10,4)) AS ink_cost, (t2.cost_per_box / t1.number_of_pcs_per_box) as box_cost
from items t1
left join boxes t2
on t1.box_id = t2.id
