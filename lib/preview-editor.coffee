{TextEditor}  = require 'atom'
configManager = require './config-manager'
util          = require './util'
fsUtil        = require './fs-util'
pluginManager = require './plugin-manager'


class PreviewEditor extends TextEditor
  constructor: (sourceEditor) ->
    @_sourceEditor = sourceEditor

    super autoHeight: false

    shouldCompileToFile = @_sourceEditor? and fsUtil.isPathInSrc(@_sourceEditor.getPath()) and
      pluginManager.isSelectionLanguageSupported(@_sourceEditor, true)

    @disposables.add(
      @_sourceEditor.onDidSave =>
        shouldWriteToFile = shouldCompileToFile and configManager.get('compileOnSave') and not
            configManager.get('compileOnSaveWithoutPreview')

        util.renderAndSave previewEditor, @_sourceEditor, shouldWriteToFile
    )

    if shouldCompileToFile and (configManager.get('compileOnSave') or
        configManager.get('compileOnSaveWithoutPreview'))
      util.compileToFile @_sourceEditor

    # HACK: Override TextBuffer save function since there is no buffer content
    # TODO: Subscribe to saveAs event and convert the editor to use that file
    @getBuffer().save = ->

  getTitle: -> "Compiled #{@_sourceEditor?.getTitle() or ''}".trim()
  getURI: -> "coffeecompile://editor/#{@_sourceEditor.id}"

  setText: (text) ->
    grammar = atom.grammars.selectGrammar pluginManager.getCompiledScopeByEditor(@_sourceEditor)
    @setGrammar(grammar)
    super text

  shouldPromptToSave: -> false

module.exports = PreviewEditor
