var sql = 'SELECT * from information_schema.tables'

function generate_tables(plv8) /*text[]*/{
  return plv8.execute(sql).map(function(x) { return x.table_name}).sort()
}

module.exports.generate_tables = generate_tables;
