configManager  = require '../config-manager'
resolve        = require 'resolve'
path           = require 'path'

# Check if there is a local coffee-script package, use that package if it exists
scopedRequire = (filepath) ->
  basedir = path.dirname(filepath)

  rst = null
  try rst = path.dirname(resolve.sync('coffee-script', { basedir }))
  if rst then require rst else require 'coffee-script'

module.exports =
  id: 'coffee-compile'
  selector: [
    'source.coffee'
    'source.litcoffee'
    'text.plain'
    'text.plain.null-grammar',
    'source.coffee.embedded.html'
  ]
  compiledScope: 'source.js'
  preCompile: (code, editor) ->
    return code

  compile: (code, editor) ->
    filepath = editor.getPath()

    coffee = if filepath then scopedRequire(filepath) else require('coffee-script')
    literate = editor.getGrammar().scopeName is "source.litcoffee"

    bare  = configManager.get('noTopLevelFunctionWrapper')
    bare ?= true

    return coffee.compile code, {bare, literate}

  postCompile: (code, editor) ->
    return code
