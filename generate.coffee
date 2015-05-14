require('coffee-script/register');
Module = require("module")

plexport_prefix = 'pl_'
currentModule = null
modules_idx = {}
plv8_exports = {}

oldrequire = Module::require

Module::require = (fl) ->
  currentModule = fl
  oldrequire.apply this, arguments

oldcompile = Module::_compile

Module::_compile = (answer, filename) ->
  modules_idx[currentModule] =
    filename: filename
    code: answer
  res = oldcompile.apply(this, arguments)
  for k,v of @exports when k.indexOf(plexport_prefix) == 0
      plv8_exports[k] ={fn: v, filename: filename}
  res

scan = (pth) ->
  currentModule = null
  modules_idx = {}
  plv8_exports = {}

  file = require(pth)
  for k,v of plv8_exports
    console.log(generate_plv8_fn(pth, k, modules_idx, v.fn))

generate_plv8_fn = (mod, k, modules_idx, fn)->
  def_fn = fn.meta || "() returns json"
  def_call = fn.toString().split("{")[0].split("function")[1].trim()
  mods = []

  for m of modules_idx
    mods.push "deps['#{m}'] = function(module, exports, require){#{modules_idx[m].code}};"

  """
  CREATE OR REPLACE FUNCTION #{k}#{def_fn} AS $$
  var deps = {}
  var cache = {}
  #{mods.join("\n")}
  var require = function(dep){
    if(!cache[dep]) {
      var module = {exports: {}};
      deps[dep](module, module.exports, require);
      cache[dep] = module.exports;
    }
    return cache[dep]
  }
  return require('#{mod}').#{k}#{def_call};
  $$ LANGUAGE plv8 IMMUTABLE STRICT;


  """

scan './src/schema'
