plv8 = require('./src/plv8')
util = require('./src/util')

xpath2array = (xpath)->
  for e in xpath.split('/')
    e.split('f:')[1]

find_parameter = (resource_type, name)->
  res = plv8.execute """
    select content
      from searchparameter
     where  content->>'base' = $1
       and content->>'name' = $2
   """, [resource_type, name]
  res[0].content if res[0]

find_definition = (resource_type)->
  res = plv8.execute('select content from structuredefinition where logical_id = $1', [resource_type])
  res[0].content if res[0]

index_definition = (def)->
  idx = {}
  for el in def.snapshot.element
    idx[el.path] = el
  idx


#TODO: do it on searchparam insert
def = find_definition('StructureDefinition')
idx = index_definition(def)
param = find_parameter('StructureDefinition', 'name')
param.path = xpath2array(param.xpath)
param.element = idx[param.path.join('.')]

table_name = util.table_name(param.base)

#console.log(param)
etype = param.element.type[0].code.toLowerCase()
cond  = "idx_#{etype}_as_#{param.type}(content::json, '#{param.path.join('.')}') ilike $1"

sql = """
  select * from #{table_name}
    where #{cond}
"""
console.log(sql)
res = plv8.execute(sql, ["%med%"])

console.log(res.map((x)-> x.content.description))
