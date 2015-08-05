{TextEditor}  = require 'atom'
configManager = require './config-manager'
fsUtil        = require './fs-util'
pluginManager = require './plugin-manager'
util          = require './util'

module.exports =
class CoffeeCompileEditor extends TextEditor
  constructor: ({@sourceEditor}) ->
    super

    shouldCompileToFile = @sourceEditor? and fsUtil.isPathInSrc(@sourceEditor.getPath())

    if shouldCompileToFile and configManager.get('compileOnSave') and not
        configManager.get('compileOnSaveWithoutPreview')
      @disposables.add @sourceEditor.getBuffer().onDidSave => @renderAndSave()
      @disposables.add @sourceEditor.getBuffer().onDidReload => @renderAndSave()

    # set editor grammar to correct language
    grammar = atom.grammars.selectGrammar pluginManager.getCompiledScopeByEditor(@sourceEditor)
    @setGrammar grammar

    if shouldCompileToFile and (configManager.get('compileOnSave') or
        configManager.get('compileOnSaveWithoutPreview'))
      util.compileToFile @sourceEditor

    # HACK: Override TextBuffer saveAs function
    @buffer.saveAs = ->

  renderAndSave: ->
    @renderCompiled()
    util.compileToFile @sourceEditor

  renderCompiled: ->
    code = util.getSelectedCode @sourceEditor

    try
      text = util.compile code, @sourceEditor
    catch e
      text = e.stack

    @setText text

  getTitle: -> "Compiled #{@sourceEditor?.getTitle() or ''}".trim()
  getURI:   -> "coffeecompile://editor/#{@sourceEditor.id}"
