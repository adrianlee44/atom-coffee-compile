fsUtil        = require './fs-util'
pluginManager = require './plugin-manager'

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
  @param {Editor} editor
  @returns {String} Compiled code
  ###
  compile: (code, editor) ->
    language = pluginManager.getLanguageByScope editor.getGrammar().scopeName

    return code unless language?

    for preCompiler in language.preCompilers
      code = preCompiler code, editor

    for compiler in language.compilers
      code = compiler code, editor

    for postCompiler in language.postCompilers
      code = postCompiler code, editor

    return code

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
  @name compileToFile
  @param {Editor} editor
  @param {Function} callback
  ###
  compileToFile: (editor, callback) ->
    try
      text     = @compile editor.getText(), editor
      srcPath  = editor.getPath()
      destPath = fsUtil.resolvePath editor.getPath()
      destPath = fsUtil.toExt destPath, 'js'
      fsUtil.writeFile destPath, text, callback

    catch e
      console.error "Coffee-compile: #{e.stack}"
