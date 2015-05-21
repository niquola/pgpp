#should be recursive
_joins = (q)->
  return "" unless q.joins
  res = for k,v of q.joins
    " JOIN #{v.resource} ??? ON ???joincond??? #{_conds(v)}"
  res.join "\n"

# _expressions lookup table
# paramType:
#   elementType:
#     operator:

_expressions =
  _else: (p)-> "#{p.param.name} = ???"
  number: {}
  token: {}
  reference: {}
  composite: {}
  quantity: {}
  uri: {}
  date:
    date:
      gt: (p)-> "#{p.param.name} in ???"
      _else: (p)-> "#{p.param.name} = ???"
  string:
    humanname:
      eq: (p)-> "#{p.param.name} ilike ???"
      _else: (p)-> "#{p.param.name} = ???"

_cond_expression = (p)->
  etype = _expressions[p.param.type] || _expressions._else
  op = etype[p.element.type.toLowerCase()] || st._else
  proc = op[p.operator] || op._else
  proc(p)

_conds = (q)->
  res = for p in q.params[1..]
    _cond_expression(p)
  if res.length > 0
    " WHERE #{res.join(" AND ")}"
  else

_query = (q)->
  tbl = q.resourceType.toLowerCase()
  """
  SELECT *
    FROM #{tbl}
  #{_joins(q)}
  #{_conds(q)}
  ???order&paging???
  """

exports.sql = _query
