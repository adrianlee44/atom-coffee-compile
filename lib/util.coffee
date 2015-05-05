coffee = require 'coffee-script'
fsUtil = require './fs-util'

cjsx_transform = null

module.exports =
  ###
  @name getTextEditorById
  @param {String} id
  @returns {Editor|null}
  ###
  getTextEditorById: (id) ->
    for editor in atom.workspace.getTextEditors()
      return editor if editor.id?.toString() is id.toString()

    return null

  ###
  @name compile
  @param {String} code
  @param {Boolean} literate (default false)
  @returns {String} Compiled code
  ###
  compile: (code, literate = false) ->
    bare  = atom.config.get('coffee-compile.noTopLevelFunctionWrapper')
    bare ?= true

    if atom.config.get('coffee-compile.compileCjsx')
      unless cjsx_transform
        cjsx_transform = require 'coffee-react-transform'
      code = cjsx_transform(code)

    return coffee.compile code, {bare, literate}

  ###
  @name getSelectedCode
  @param {Editor} editor
  @returns {String} Selected text
  ###
  getSelectedCode: (editor) ->
    range = editor.getSelectedBufferRange()
    text  =
      if range.isEmpty()
        editor.getText()
      else
        editor.getTextInBufferRange range

    return text

  ###
  @name isLiterate
  @param {Editor} editor
  @returns {Boolean}
  ###
  isLiterate: (editor) ->
    grammarScopeName = editor.getGrammar().scopeName
    return grammarScopeName is "source.litcoffee"

  ###
  @name compileToFile
  @param {Editor} editor
  @param {Function} callback
  ###
  compileToFile: (editor, callback) ->
    try
      literate = @isLiterate editor
      text     = @compile editor.getText(), literate
      srcPath  = editor.getPath()
      destPath = fsUtil.resolvePath editor.getPath()
      destPath = fsUtil.toExt destPath, 'js'
      fsUtil.writeFile destPath, text, callback

    catch e
      console.error "Coffee-compile: #{e.stack}"

  checkGrammar: (editor) ->
    grammars = atom.config.get('coffee-compile.grammars') or []
    return editor.getGrammar().scopeName in grammars
