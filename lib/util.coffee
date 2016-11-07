configManager = require './config-manager'
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
  @param {Editor} editor
  @returns {String} Compiled code
  ###
  compile: (editor) ->
    language = pluginManager.getLanguageByScope editor.getGrammar().scopeName

    code = @getSelectedCode editor

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

      text     = @compile editor
      destPath = fsUtil.resolvePath editor.getPath()

      unless atom.project.contains(destPath)
        atom.notifications.addError "Compile-compile: Failed to compile to file",
          detail: "Cannot write outside of project root"

      destPath = fsUtil.toExt destPath, 'js'
      fsUtil.writeFile destPath, text

    catch e
      atom.notifications.addError "Compile-compile: Failed to compile to file",
        detail: e.stack

  compileOrStack: (editor) ->
    try
      text = @compile editor
    catch e
      text = e.stack

    return text

  renderAndSave: (editor, sourceEditor, shouldWriteToFile = true) ->
    text = @compileOrStack sourceEditor

    editor.setText text

    @compileToFile(sourceEditor) if shouldWriteToFile

  buildCoffeeCompileEditor: (sourceEditor) ->
    previewEditor = atom.workspace.buildTextEditor(autoHeight: false)

    shouldCompileToFile = sourceEditor? and fsUtil.isPathInSrc(sourceEditor.getPath()) and
      pluginManager.isEditorLanguageSupported(sourceEditor, true)

    previewEditor.disposables.add(
      sourceEditor.onDidSave =>
        shouldWriteToFile = shouldCompileToFile and configManager.get('compileOnSave') and not
            configManager.get('compileOnSaveWithoutPreview')

        @renderAndSave previewEditor, sourceEditor, shouldWriteToFile
    )

    # set editor grammar to correct language
    grammar = atom.grammars.selectGrammar pluginManager.getCompiledScopeByEditor(sourceEditor)
    previewEditor.setGrammar grammar

    if shouldCompileToFile and (configManager.get('compileOnSave') or
        configManager.get('compileOnSaveWithoutPreview'))
      @compileToFile sourceEditor

    # HACK: Override TextBuffer save function since there is no buffer content
    # TODO: Subscribe to saveAs event and convert the editor to use that file
    previewEditor.getBuffer().save = ->

    # HACK: Override getURI and getTitle
    previewEditor.getTitle = -> "Compiled #{sourceEditor?.getTitle() or ''}".trim()
    previewEditor.getURI   = -> "coffeecompile://editor/#{sourceEditor.id}"

    # Should never prompt to save on preview editor
    previewEditor.shouldPromptToSave = -> false

    return previewEditor
