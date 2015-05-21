plv8 = require('./lib/plv8')
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
  console.log("Load bundle #{nm}")
  bndl = require("./data/#{nm}.json")
  crud.load_bundle(plv8, bndl)

load_metadata = ()->
  for rs in BASE_RESOURCES
    sch.drop_table(plv8, rs)
    console.log("Generate table for #{rs}")
    sch.generate_table(plv8, rs)

  load_bundle('profiles-types')
  load_bundle('profiles-resources')
  load_bundle('search-parameters')

  for bndl in ['valuesets'] #, 'v2-tables', 'v3-codesystems.json']
    load_bundle(bndl)

load_functions = ()->
  plv8.execute('DROP SCHEMA IF EXISTS fhir CASCADE')
  plv8.execute('CREATE SCHEMA fhir')
  np = require('./lib/node2pl')
  np.scan './src/crud'
  np.scan './src/json'
  np.scan './src/idx'
  np.scan './src/search'

init()
load_metadata()
load_functions()
