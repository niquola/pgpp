fs = require('fs')
coffee = require("coffee-script")

global.plv8_export = (nm, fl, fn)->
  src = fs.readFileSync(fl).toString()
  code = coffee.compile(src,
    literate: false,
    filename: fl,
    debug: true,
    bare: true,
    sourceMap: true,
    sourceRoot: "",
    generatedFile: 'x')

  console.log("""
  CREATE OR REPLACE FUNCTION #{nm} AS $$
  var module = {exports: {}}
  var global = {}
  #{code.js}
  return (#{fn.toString()})(plv8);
  $$ LANGUAGE plv8 IMMUTABLE STRICT;
  """)
require('./src/schema')
