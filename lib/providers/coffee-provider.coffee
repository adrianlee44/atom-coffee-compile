coffee         = require 'coffee-script'
configManager  = require '../config-manager'
cjsx_transform = null

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
    if configManager.get('compileCjsx')
      unless cjsx_transform
        cjsx_transform = require 'coffee-react-transform'

      code = cjsx_transform code

    return code

  compile: (code, editor) ->
    literate = editor.getGrammar().scopeName is "source.litcoffee"

    bare  = configManager.get('noTopLevelFunctionWrapper')
    bare ?= true

    return coffee.compile code, {bare, literate}

  postCompile: (code, editor) ->
    return code
