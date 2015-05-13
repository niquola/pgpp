var plv8 = require('../src/plv8')
var schema = require('../src/schema')

console.log('here');

console.log(schema.generate_tables(plv8));

describe("A suite", function() {
  it("contains spec with an expectation", function() {
    var res = schema.generate_tables(plv8);
    expect(res.length > 0).toBe(true);
  });
});
