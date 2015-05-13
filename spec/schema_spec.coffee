plv8 = require('../src/plv8')
schema = require('../src/schema')

describe "A suite", ()->
  it "contains spec with an expectation", ()->
    res = schema.generate_tables(plv8)
    expect(res.length > 0).toBe(true)
