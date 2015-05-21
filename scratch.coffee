plv8 = require('./lib/plv8')
search = require('./src/search')
sql = require('./src/honey').sql

res = search.search_sql(plv8, 'StructureDefinition', 'name', 'enc')
console.log(res)

read = (rt, id)->
  sql({select: [':content'], from: [rt.toLowerCase()], where: [':=',':logical_id', id]})

console.log read('Patient', 'x')
#console.log search.search(plv8, 'StructureDefinition', 'name', 'enco').length
