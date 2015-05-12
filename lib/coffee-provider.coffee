coffee = require 'coffee-script'
util = require './util'
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
    if atom.config.get('coffee-compile.compileCjsx')
      unless cjsx_transform
        cjsx_transform = require 'coffee-react-transform'

      code = cjsx_transform code

    return code

  compile: (code, editor) ->
    literate = editor.getGrammar().scopeName is "source.litcoffee"

    bare  = atom.config.get('coffee-compile.noTopLevelFunctionWrapper')
    bare ?= true

    return coffee.compile code, {bare, literate}

  postCompile: (code, editor) ->
    return code
