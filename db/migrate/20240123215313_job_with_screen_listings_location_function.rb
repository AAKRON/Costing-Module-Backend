class JobWithScreenListingsLocationFunction < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_jobs(IN location_id_param INT)
            RETURNS TABLE (
            id INT,
            description VARCHAR,
            job_number INT,
            screen_size VARCHAR,
            screen_id INT,
            wages_per_hour DOUBLE PRECISION
            ) AS $$
            BEGIN
                return query
                select
                        jl.id,
                        jl.description,
                        jl.job_number,
                        s.screen_size,
                        jl.screen_id,
                        CASE
                            WHEN job_location_prices.wages_per_hour IS NOT NULL THEN job_location_prices.wages_per_hour
                            ELSE jl.wages_per_hour
                        END AS wages_per_hour
                from job_listings jl
                left join screens s on s.id=jl.screen_id
                left join job_location_prices on job_location_prices.job_listings_id = jl.id and job_location_prices.locations_id = location_id_param
                GROUP BY jl.id, s.screen_size, job_location_prices.wages_per_hour
                ORDER BY jl.id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_blanks(integer)
        ))
    end
end
