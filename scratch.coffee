plv8 = require('./lib/plv8')
search = require('./src/search')

res = search.search_sql(plv8, 'StructureDefinition', 'name', 'enc')
console.log(res)

console.log search.search(plv8, 'StructureDefinition', 'name', 'enco').length
