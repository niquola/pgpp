require('coffee-script/register')
Module = require("module")

currentModule = null
modules_idx = {}
plv8_exports = {}

oldrequire = Module::require

Module::require = (fl) ->
  currentModule = fl
  oldrequire.apply this, arguments

oldcompile = Module::_compile

Module::_compile = (answer, filename) ->
  modules_idx[currentModule] ={ filename: filename, code: answer}
  res = oldcompile.apply(this, arguments)
  for k,v of @exports when v.plv8?
      plv8_exports[k] ={fn: v, filename: filename}
  res

scan = (pth) ->
  currentModule = null
  modules_idx = {}
  plv8_exports = {}

  delete require.cache

  file = require(pth)
  modules_js = generate_modules(modules_idx)
  for k,v of plv8_exports
    console.log(generate_plv8_fn(pth, k, modules_js, v.fn))

generate_modules = (modules_idx)->
  mods = []
  for m,v of modules_idx
    mods.push "deps['#{m}'] = function(module, exports, require){#{v.code}};"
  mods.join("\n")

generate_plv8_fn = (mod, k, modules_js, fn)->
  def_fn = fn.plv8
  def_call = fn.toString().split("{")[0].split("function")[1].trim()

  """
  CREATE OR REPLACE FUNCTION #{def_fn} AS $$
  var deps = {}
  var cache = {}
  #{modules_js}
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

#scan './src/crud'
#scan './src/json'
scan './src/idx'
