select i.id, i.item_number, i.description, count(ij.item_id) as number_of_jobs
from items i
left join item_jobs ij on ij.item_id = i.id
group by i.id
