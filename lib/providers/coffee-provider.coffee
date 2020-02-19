configManager = require '../config-manager'
resolve       = require 'resolve'
path          = require 'path'

getCompiler = (editor) ->
  filepath = editor.getPath()

  coffee = if filepath then maybeGetLocalCoffeescript(filepath)
  if coffee? then return coffee

  coffeescriptVersion = configManager.get('coffeescriptVersion')
  switch coffeescriptVersion
    when '2.5.1'
      return require('coffeescript')
    else # default back to 1.12.7
      return require('coffee-script')

# Check if there is a local coffee-script package, use that package if it exists
# Convert this lookup to an option
maybeGetLocalCoffeescript = (filepath) ->
  basedir = path.dirname(filepath)

  rst = null
  try
    # Check for CS v1
    rst = path.dirname(resolve.sync('coffee-script', { basedir }))
    if not rst
      rst = path.dirname(resolve.sync('coffeescript', { basedir }))

  if rst then require rst

module.exports =
  id: 'coffee-compile'
  selector: [
    'source.coffee'
    'source.litcoffee'
    'text.plain.null-grammar'
    'source.embedded.coffee'
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
