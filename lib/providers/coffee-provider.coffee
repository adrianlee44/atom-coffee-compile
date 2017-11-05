configManager = require '../config-manager'
resolve       = require 'resolve'
path          = require 'path'

getCompiler = (editor) ->
  filepath = editor.getPath()

  coffee = if filepath then maybeGetLocalCoffeescript(filepath)
  if coffee? then return coffee

  coffeescriptVersion = configManager.get('coffeescriptVersion')
  switch coffeescriptVersion
    when '2.0.2'
      return require('../../coffee-bin/2.0.2/lib/coffeescript/index')
    else # default back to 1.12.7
      return require('../../coffee-bin/1.12.7/lib/coffee-script/coffee-script')

# Check if there is a local coffee-script package, use that package if it exists
maybeGetLocalCoffeescript = (filepath) ->
  basedir = path.dirname(filepath)

  rst = null
  try rst = path.dirname(resolve.sync('coffee-script', { basedir }))
  if rst then require rst

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
    coffee = getCompiler editor
    literate = editor.getGrammar().scopeName is "source.litcoffee"

    bare  = configManager.get('noTopLevelFunctionWrapper')
    bare ?= true

    return coffee.compile code, {bare, literate}

  postCompile: (code, editor) ->
    return code
