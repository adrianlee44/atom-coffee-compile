url         = require 'url'
querystring = require 'querystring'

CoffeeCompileView = require './coffee-compile-view'

module.exports =
  configDefaults:
    grammars: [
      'source.coffee'
      'source.litcoffee'
      'text.plain'
      'text.plain.null-grammar'
    ]
    noTopLevelFunctionWrapper: true
    compileOnSave: false
    compileOnSaveWithoutPreview: false
    focusEditorAfterCompile: false

  activate: ->
    atom.workspaceView.command 'coffee-compile:compile', => @display()

    if atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      atom.workspaceView.command 'core:save', => @save()

    atom.workspace.registerOpener (uriToOpen) ->
      {protocol, host, pathname} = url.parse uriToOpen
      pathname = querystring.unescape(pathname) if pathname

      return unless protocol is 'coffeecompile:'

      new CoffeeCompileView
        sourceEditorId: pathname.substr(1)

  save: ->
    editor = atom.workspace.getActiveEditor()

    return unless editor?

    CoffeeCompileView.saveCompiled editor

  display: ->
    editor     = atom.workspace.getActiveEditor()
    activePane = atom.workspace.getActivePane()

    return unless editor?

    grammars = atom.config.get('coffee-compile.grammars') or []
    unless (grammar = editor.getGrammar().scopeName) in grammars
      console.warn("Cannot compile non-Coffeescript to Javascript")
      return

    uri = "coffeecompile://editor/#{editor.id}"

    atom.workspace.open uri,
      searchAllPanes: true
      split: "right"
    .done (coffeeCompileView) ->
      if coffeeCompileView instanceof CoffeeCompileView
        coffeeCompileView.renderCompiled()

        if atom.config.get('coffee-compile.compileOnSave') or
            atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
          CoffeeCompileView.saveCompiled editor

        if atom.config.get('coffee-compile.focusEditorAfterCompile')
          activePane.activate()
