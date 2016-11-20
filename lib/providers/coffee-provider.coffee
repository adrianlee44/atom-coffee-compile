configManager  = require '../config-manager'
resolve        = require 'resolve'
path           = require 'path'

scopedRequire = (basedir, modName) ->
  rst = null
  try rst = path.dirname(resolve.sync(modName, { basedir }))
  if rst then require "#{rst}" else require modName

module.exports =
  id: 'coffee-compile'
  selector: [
    'source.coffee'
    'source.litcoffee'
    'text.plain'
    'text.plain.null-grammar'
  ]
  compiledScope: 'source.js'
  preCompile: (code, editor) ->
    return code

  compile: (code, editor) ->
    coffee = scopedRequire path.dirname(editor.getPath()), 'coffee-script'
    literate = editor.getGrammar().scopeName is "source.litcoffee"

    bare  = configManager.get('noTopLevelFunctionWrapper')
    bare ?= true

    return coffee.compile code, {bare, literate}

  postCompile: (code, editor) ->
    return code
