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
  for k of plv8_exports
    console.log(generate_plv8_fn(pth, k, modules_idx))

generate_plv8_fn = (mod, k, modules_idx)->
  mods = []

  for m of modules_idx
    mods.push "deps['#{m}'] = function(module, require){#{modules_idx[m].code}};"

  """
  CREATE OR REPLACE FUNCTION #{k}() returns json AS $$
  var deps = {}
  var cache = {}
  #{mods.join("\n")}
  var require = function(dep){
    if(!cache[dep]) {
      var module = {exports: {}};
      deps[dep](module, require);
      cache[dep] = module.exports;
    }
    return cache[dep]
  }
  return require('#{mod}').#{k}(plv8);
  $$ LANGUAGE plv8 IMMUTABLE STRICT;
  """

scan './src/schema'
