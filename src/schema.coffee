sql = require('./util')

module.exports.pl_tables = (plv8)->
  return plv8.execute(sql)
    .map((x) -> x.table_name)
    .sort()
