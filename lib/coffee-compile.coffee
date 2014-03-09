url         = require 'url'
querystring = require 'querystring'

CoffeeCompileView = require './coffee-compile-view'

module.exports =
  coffeeCompileView: null

  activate: (state) ->
    atom.workspaceView.command 'coffee-compile:compile', => @display()

    atom.workspace.registerOpener (uriToOpen) ->
      {protocol, pathname} = url.parse uriToOpen
      pathname = querystring.unescape(pathname) if pathname

      return unless protocol is 'coffeecompile:'
      new CoffeeCompileView(pathname)

  display: ->
    editor     = atom.workspace.getActiveEditor()
    activePane = atom.workspace.getActivePane()

    return unless editor?

    unless editor.getGrammar().scopeName is "source.coffee"
      console.warn("Cannot compile non-Coffeescript to Javascript")
      return

    range = editor.getSelectedBufferRange()
    code  =
      if range.isEmpty()
        editor.getText()
      else
        editor.getTextInBufferRange(range)

    uri = "coffeecompile://#{editor.getPath()}"

    # If a pane with the uri
    pane = atom.workspace.paneContainer.paneForUri uri
    # If not, always split right
    pane ?= activePane.splitRight()

    atom.workspace.openUriInPane(uri, pane, {}).done (coffeeCompileView) ->
      if coffeeCompileView instanceof CoffeeCompileView
        coffeeCompileView.setCode(code)
        coffeeCompileView.renderCompiled()
