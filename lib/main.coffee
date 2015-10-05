url         = require 'url'
querystring = require 'querystring'
cson        = require 'season'

CoffeeCompileEditor = require './coffee-compile-editor'
coffeeProvider      = require './providers/coffee-provider'
configManager       = require './config-manager'
fsUtil              = require './fs-util'
pluginManager       = require './plugin-manager'
util                = require './util'
{CompositeDisposable} = require 'atom'

module.exports =
  config: require '../config'
  activate: ->
    configManager.initProjectConfig()

    @saveDisposables = new CompositeDisposable
    @pkgDisposables = new CompositeDisposable

    atom.commands.add 'atom-workspace', 'coffee-compile:compile': => @display()

    @pkgDisposables.add configManager.observe 'compileOnSaveWithoutPreview', (value) =>
      @saveDisposables.dispose()
      @saveDisposables = new CompositeDisposable

      if value
        @saveDisposables.add atom.workspace.observeTextEditors (editor) =>
          @saveDisposables.add editor.onDidSave =>
            @save(editor)

    # NOTE: Remove once coffeescript provider is moved to a new package
    unless pluginManager.isPluginRegistered(coffeeProvider)
      @registerProviders coffeeProvider

    @pkgDisposables.add atom.workspace.addOpener (uriToOpen) ->
      {protocol, pathname} = url.parse uriToOpen
      pathname = querystring.unescape(pathname) if pathname

      return unless protocol is 'coffeecompile:'

      sourceEditorId = pathname.substr(1)
      sourceEditor   = util.getTextEditorById sourceEditorId

      return unless sourceEditor?

      return new CoffeeCompileEditor {sourceEditor}

  deactivate: ->
    @pkgDisposables.dispose()

  save: (editor) ->
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

    @open "coffeecompile://editor/#{editor.id}"
    .then (editor) ->
      editor.renderCompiled()

      if configManager.get('focusEditorAfterCompile')
        activePane.activate()

  # Similar to atom.workspace.open
  # @param {string} A string containing a URI
  # @return {Promise.<TextEditor>}
  open: (uri) ->
    uri = atom.project.resolvePath uri

    pane = atom.workspace.paneForURI(uri)
    pane ?= switch configManager.get('split').toLowerCase()
      when 'left'
        atom.workspace.getActivePane().splitLeft()
      when 'right'
        atom.workspace.getActivePane().findOrCreateRightmostSibling()
      when 'down'
        atom.workspace.getActivePane().splitDown()
      when 'up'
        atom.workspace.getActivePane().splitUp()
      else
        atom.workspace.getActivePane()

    atom.workspace.openURIInPane(uri, pane)

  registerProviders: (provider) ->
    pluginManager.register provider
