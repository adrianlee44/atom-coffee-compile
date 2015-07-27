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
  ###
  compileToFile: (editor) ->
    try
      srcPath = editor.getPath()

      return unless fsUtil.isPathInSrc srcPath

      text     = @compile editor.getText(), editor
      destPath = fsUtil.resolvePath editor.getPath()

      unless atom.project.contains(destPath)
        atom.notifications.addError "Compile-compile: Failed to compile to file",
          detail: "Cannot write outside of project root"

      destPath = fsUtil.toExt destPath, 'js'
      fsUtil.writeFile destPath, text

    catch e
      atom.notifications.addError "Compile-compile: Failed to compile to file",
        detail: e.stack
