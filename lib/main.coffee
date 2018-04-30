url         = require 'url'
querystring = require 'querystring'
cson        = require 'season'

coffeeProvider      = require './providers/coffee-provider'
configManager       = require './config-manager'
pluginManager       = require './plugin-manager'
util                = require './util'
{CompositeDisposable} = require 'atom'
PreviewEditor = require './preview-editor'

module.exports =
  activate: ->
    configManager.initProjectConfig()

    @saveDisposables = new CompositeDisposable
    @pkgDisposables = new CompositeDisposable

    atom.commands.add 'atom-workspace', 'coffee-compile:compile': => @display()

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

      new PreviewEditor sourceEditor

  deactivate: ->
    @pkgDisposables.dispose()

  display: ->
    editor     = atom.workspace.getActiveTextEditor()
    activePane = atom.workspace.getActivePane()

    return unless editor?

    unless pluginManager.isSelectionLanguageSupported editor
      return console.warn("Coffee compile: Invalid language")

    @open "coffeecompile://editor/#{editor.id}"
    .then (previewEditor) ->
      compiled = util.compileOrStack editor
      previewEditor.setText compiled

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
