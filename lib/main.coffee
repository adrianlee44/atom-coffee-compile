url         = require 'url'
querystring = require 'querystring'

CoffeeCompileEditor = require './coffee-compile-editor'
util                = require './util'
pluginManager       = require './plugin-manager'
coffeeProvider      = require './coffee-provider'
fsUtil              = require './fs-util'

module.exports =
  config: require '../config'
  activate: ->
    saveDisposables = []

    atom.commands.add 'atom-workspace', 'coffee-compile:compile': => @display()

    atom.config.observe 'coffee-compile.compileOnSaveWithoutPreview', (value) =>
      if not value and saveDisposables.length > 0
        sd.dispose() for sd in saveDisposables
        saveDisposables = []

      else if value
        saveDisposables = []
        saveDisposables.push atom.workspace.observeTextEditors (editor) =>
          saveDisposables.push editor.onDidSave =>
            @save(editor)

    # NOTE: Remove once coffeescript provider is moved to a new package
    unless pluginManager.isPluginRegistered(coffeeProvider)
      @registerProviders coffeeProvider

    atom.workspace.addOpener (uriToOpen) ->
      {protocol, pathname} = url.parse uriToOpen
      pathname = querystring.unescape(pathname) if pathname

      return unless protocol is 'coffeecompile:'

      sourceEditorId = pathname.substr(1)
      sourceEditor   = util.getTextEditorById sourceEditorId

      return unless sourceEditor?

      return new CoffeeCompileEditor {sourceEditor}

  save: (editor)->
    return unless editor?

    isPathInSrc = !!editor.getPath() and fsUtil.isPathInSrc(editor.getPath())

    if isPathInSrc and pluginManager.isEditorLanguageSupported(editor)
      util.compileToFile editor

  display: ->
    editor     = atom.workspace.getActiveTextEditor()
    activePane = atom.workspace.getActivePane()

    return unless editor?

    unless pluginManager.isEditorLanguageSupported editor
      return console.warn("Coffee compile: Invalid language")

    atom.workspace.open "coffeecompile://editor/#{editor.id}",
      searchAllPanes: true
      split: "right"
    .then (editor) ->
      editor.renderCompiled()

      if atom.config.get('coffee-compile.focusEditorAfterCompile')
        activePane.activate()

  registerProviders: (provider) ->
    pluginManager.register provider
