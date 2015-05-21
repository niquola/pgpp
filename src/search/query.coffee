querySchema:
  resource: 'ResourceType'
  on: 'Join condition? calculatable'
  # ??? use params
  joins:
    searchReference: querySchema
    searchReference2: querySchema
  params: [
    'and' #logical grouping
    param: # search parameter type
      name:
      type:
    element: #element path
      path: 'path to element i.e. Patient.name'
      type: 'type of element'
  ]

query =
  resource: 'Encounter',
  params: [
    'and',
     {param:
       name: 'name'
       type: 'string'
     element:
       path: 'Patient.name'
       type: 'HumanName'
     operator: '=',
     value: ['x','y']},
     {param:
       name: 'birthDate'
       type: 'string'
     element:
       path: 'Patient.name'
       type: 'HumanName'
     operator: '=',
     value: ['x','y']}
  ]
  joins:
    subject:
      resource: 'Patient'
      on: ["logical_ids(content, '{subject}')", "logical_id"]
      params:[
        'and',
        param: {name: 'name', type: 'string'}
        element: {path: 'Patient.name', type: 'HumanName'}
        operator: '='
        value: ['x','y']

        param: {name: 'name', type: 'string'}
        element: {path: 'Patient.name', type: 'HumanName'}
        operator: '='
        value: ['x','y']
      ]

#should be recursive
_joins = (q)->
  return "" unless q.joins
  res = for k,v of q.joins
    " JOIN #{v.resource} ??? ON ???joincond??? #{_conds(v)}"
  res.join "\n"

_conds = (q)->
  res = for p in q.params[1..]
    "#{p.param.name} = ???"
  if res.length > 0
    " WHERE #{res.join(" AND ")}"
  else

_query = (q)->
  tbl = q.resource.toLowerCase()
  """
  SELECT *
    FROM #{tbl}
  #{_joins(q)}
  #{_conds(q)}
  """

console.log _query(query)

