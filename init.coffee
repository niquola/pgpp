plv8 = require('./src/plv8')
sch = require('./src/schema')
crud = require('./src/crud')

init = ()->
 sch.init(plv8)


BASE_RESOURCES = [
  'StructureDefinition'
  'SearchParameter'
  'ValueSet'
  'OperationDefinition'
  'Conformance'
]

load_bundle = (nm)->
  bndl = require("./data/#{nm}.json")
  crud.load_bundle(plv8, bndl)

load_metadata = ()->
  for rs in BASE_RESOURCES
    sch.drop_table(plv8, rs)
    sch.generate_table(plv8, rs)

  load_bundle('profiles-types')
  load_bundle('profiles-resources')
  load_bundle('search-parameters')

  for bndl in ['valuesets'] #, 'v2-tables', 'v3-codesystems.json']
    load_bundle(bndl)

#load_metadata()
