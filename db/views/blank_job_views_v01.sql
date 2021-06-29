SELECT t1.id, t1.blank_number, t1.description, count(t2.blank_id) AS number_of_jobs
FROM blanks t1
LEFT JOIN blank_jobs t2
ON t1.blank_number = t2.blank_id
GROUP BY t1.id, t1.blank_number, t1.description
