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


_normalize = (x)->
  x.replace(/ +/g,' ')

_select = (query)->
  [
    _columns(query.select)
    _tables(query.from)
    _joins(query.joins)
    _where(query.where)
  ].join(' ')


# DDL

_lit = (x)->
  "\"#{x}\""

_create_table = (q)->
  "CREATE TABLE #{_lit(q.name)}"

_columns_ddl = (q)->
  cols = (k for k,_ of q.columns).sort()
  cols = for c in cols
    "#{_lit(c)} #{q.columns[c].join(' ')}"
  cols.join(', ')

_inherits = (q)->
  "INHERITS (#{q.inherits.map(_lit).join(',')})" if q.inherits

_create = (q)->
  [
    _create_table(q)
    "("
    _columns_ddl(q)
    ")"
    _inherits(q)
  ].join(' ')

sql = (q)->
  res = if q.create
    _create(q)
  else if q.select
    _select(q)
  _normalize(res)

exports.sql = sql
