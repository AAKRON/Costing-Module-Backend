require "upsert"
require "upsert/column_definition/postgresql"

Upsert::ColumnDefinition::Postgresql.class_eval do
	def all(connection, quoted_table_name)
          res = connection.execute <<-EOS
  SELECT a.attname AS name, format_type(a.atttypid, a.atttypmod) AS sql_type, pg_get_expr(d.adbin, d.adrelid) AS default
  FROM pg_attribute a LEFT JOIN pg_attrdef d
  ON a.attrelid = d.adrelid AND a.attnum = d.adnum
  WHERE a.attrelid = '#{quoted_table_name}'::regclass
  AND a.attnum > 0 AND NOT a.attisdropped
  EOS
	end  
end


