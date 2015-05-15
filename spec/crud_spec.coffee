plv8 = require('../src/plv8')
crud = require('../src/crud')

describe "CRUD", ()->
  it "read", ()->
    res = crud.read(plv8,'StructureDefinition', 'Patient')
    expect(res.resourceType).toEqual('StructureDefinition')
