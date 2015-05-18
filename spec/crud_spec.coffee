plv8 = require('../lib/plv8')
crud = require('../src/crud')

test_read = (res)->
  res = JSON.parse(res)
  expect(res.resourceType).toEqual('StructureDefinition')

describe "CRUD", ()->
  it "read", ()->
    res = crud.read(plv8,'StructureDefinition', 'Patient')
    test_read(res)

  it "read in db", ()->
    np = require('../lib/node2pl')
    np.scan('../src/crud')

    res = plv8.execute("select fhir.read('StructureDefinition', 'Patient') as read")[0]['read']
    test_read(res)
