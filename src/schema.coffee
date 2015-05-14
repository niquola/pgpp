sql = require('./util')
qs = require('query-string')

module.exports.pl_tables = (plv8)->
  plv8.execute(sql)
    .map((x) -> x.routine_name)
    .sort()

module.exports.pl_tables.meta = "() RETURNS json"

module.exports.pl_add = (plv8, x, y)->
  x + y

module.exports.pl_add.meta = "(x int, y int) RETURNS int"

module.exports.pl_parse = (plv8, str)->
  qs.parse(str)

module.exports.pl_parse.meta = "(str text) RETURNS json"
