url         = require 'url'
querystring = require 'querystring'
coffee = require 'coffee-script'
fs = require 'fs'
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

  activate: ->
    atom.workspaceView.command 'coffee-compile:compile', => @display()
    atom.workspaceView.command 'coffee-compile:autocompile', (e) =>
      e.abortKeyBinding()
      @autoCompileOnSave()

    atom.workspace.registerOpener (uriToOpen) ->
      {protocol, host, pathname} = url.parse uriToOpen
      pathname = querystring.unescape(pathname) if pathname

      return unless protocol is 'coffeecompile:'
      new CoffeeCompileView(pathname.substr(1))

  display: ->
    editor     = atom.workspace.getActiveEditor()
    activePane = atom.workspace.getActivePane()

    return unless editor?

    grammars = atom.config.get('coffee-compile.grammars') or []
    unless (grammar = editor.getGrammar().scopeName) in grammars
      console.warn("Cannot compile non-Coffeescript to Javascript")
      return

    uri = "coffeecompile://editor/#{editor.id}"

    # If a pane with the uri
    pane = atom.workspace.paneContainer.paneForUri uri
    # If not, always split right
    pane ?= activePane.splitRight()

    atom.workspace.openUriInPane(uri, pane, {}).done (coffeeCompileView) ->
      if coffeeCompileView instanceof CoffeeCompileView
        coffeeCompileView.renderCompiled()

  autoCompileOnSave: ->
    editor = atom.workspace.getActiveEditor()
    path = editor.getPath()
    if path.indexOf(".coffee") > -1
      newPath = path.substr(0,path.length-6) + "js"
      compiled = coffee.compile editor.getText()
      fs.writeFile newPath, compiled
