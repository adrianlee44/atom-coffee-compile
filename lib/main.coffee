url         = require 'url'
querystring = require 'querystring'

CoffeeCompileView = require './coffee-compile-view'
util              = require './util'

module.exports =
  config:
    grammars:
      type: 'array'
      default: [
        'source.coffee'
        'source.litcoffee'
        'text.plain'
        'text.plain.null-grammar'
      ]
    noTopLevelFunctionWrapper:
      type: 'boolean'
      default: true
    compileOnSave:
      type: 'boolean'
      default: false
    compileOnSaveWithoutPreview:
      type: 'boolean'
      default: false
    focusEditorAfterCompile:
      type: 'boolean'
      default: false

  activate: ->
    atom.commands.add 'atom-workspace', 'coffee-compile:compile': => @display()

    if atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      atom.commands.add 'atom-workspace', 'core:save': => @save()

    atom.workspace.addOpener (uriToOpen) ->
      {protocol, pathname} = url.parse uriToOpen
      pathname = querystring.unescape(pathname) if pathname

      return unless protocol is 'coffeecompile:'

      new CoffeeCompileView
        sourceEditorId: pathname.substr(1)

  checkGrammar: (editor) ->
    grammars = atom.config.get('coffee-compile.grammars') or []
    return (grammar = editor.getGrammar().scopeName) in grammars

  save: ->
    editor = atom.workspace.getActiveTextEditor()

    return unless editor?

    return unless @checkGrammar editor

    util.compileToFile editor

  display: ->
    editor     = atom.workspace.getActiveTextEditor()
    activePane = atom.workspace.getActivePane()

    return unless editor?

    unless @checkGrammar editor
      return console.warn("Cannot compile non-Coffeescript to Javascript")

    atom.workspace.open "coffeecompile://editor/#{editor.id}",
      searchAllPanes: true
      split: "right"
    .then (view) ->
      uriToOpen = view.getURI()

      return unless uriToOpen

      {protocol, pathname} = url.parse uriToOpen
      pathname = querystring.unescape(pathname) if pathname

      return unless protocol is 'coffeecompile:'

      if atom.config.get('coffee-compile.focusEditorAfterCompile')
        activePane.activate()
