sql = 'SELECT * from information_schema.tables'

generate_tables = (plv8)->
  return plv8.execute(sql)
    .map((x) -> x.table_name)
    .sort()

module.exports.generate_tables = generate_tables

if global.plv8_export
  plv8_export('generate_tables() returns text[]', __filename, generate_tables)
