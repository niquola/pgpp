isArray = (value ) ->
  value and
  typeof value is 'object' and
  value instanceof Array and
  typeof value.length is 'number' and
  typeof value.splice is 'function' and
  not ( value.propertyIsEnumerable 'length' )

isKeyword = (x)->
  x.indexOf && x.indexOf(':') == 0

isNumber = (x)->
  not isNaN(parseFloat(x)) && isFinite(x)

name = (x)->
  if isKeyword(x)
    x.replace(/^:/,'')

_toLiteral = (x)->
  if isKeyword(x)
    name(x)
  else if isNumber(x)
    x
  else
    "'#{x}'"

_columns = (x)->
  return unless x
  list = x.map (x)->
    if isKeyword(x)
      name(x)
    else
      "'#{x}'"
  "SELECT #{list.join(', ')}"

_table = (y)->
  if isArray(y) then "#{y[0]} #{y[1]}" else y

_tables = (x)->
  return unless x
  throw new Exception('from: [array] expected)') unless isArray(x)
  x = x.map(_table)
  list = x.map(_table).join(', ')
  "FROM #{list}"

_expression = (x)->
  return _toLiteral(x) if not isArray(x)
  which = x[0]
  switch which
    when ':and'
      "(" + x[1..].map(_expression).join(' AND ') + ")"
    when ':or'
      "(" + x[1..].map(_expression).join(' OR ') + ")"
    else
      [_expression(x[1]), _toLiteral(x[0]), _expression(x[2])].join(" ")


_where = (x)->
  return unless x
  cond =  _expression(x)
  "WHERE #{cond}"

_joins = (x)->
  return unless x
  x.map((y)->
   "JOIN #{_table(y[0])} ON #{_expression(y[1])}"
  ).join(" ")


_select = (query)->
  [
    _columns(query.select)
    _tables(query.from)
    _joins(query.joins)
    _where(query.where)
  ].join(' ')

sql = (q)->
  _select(q)

exports.sql = sql

#console.log sql()
