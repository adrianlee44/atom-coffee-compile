coffee = require 'coffee-script'
fs     = require 'fs'
path   = require 'path'

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
  @param {Editor} editor
  @param {String} code
  @returns {String} Compiled code
  ###
  compile: (code, literate = false) ->
    bare  = atom.config.get('coffee-compile.noTopLevelFunctionWrapper')
    bare ?= true

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
      srcExt   = path.extname srcPath
      destPath = path.join(
        path.dirname(srcPath), "#{path.basename(srcPath, srcExt)}.js"
      )
      fs.writeFile destPath, text, callback

    catch e
      console.error "Coffee-compile: #{e.stack}"

  checkGrammar: (editor) ->
    grammars = atom.config.get('coffee-compile.grammars') or []
    return (grammar = editor.getGrammar().scopeName) in grammars
