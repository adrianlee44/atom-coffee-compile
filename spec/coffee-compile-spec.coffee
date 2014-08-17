CoffeeCompileView = require '../lib/coffee-compile-view'
{WorkspaceView} = require 'atom'

describe "CoffeeCompile", ->
  beforeEach ->
    atom.config.set 'core.useReactEditor', false

    atom.workspaceView = new WorkspaceView
    atom.workspace     = atom.workspaceView.model
    spyOn(CoffeeCompileView.prototype, "renderCompiled").andCallThrough()

    waitsForPromise "coffee-compile package to activate", ->
      atom.packages.activatePackage('coffee-compile')

    waitsForPromise "language-coffee-script to activate", ->
      atom.packages.activatePackage('language-coffee-script')

    atom.config.set('coffee-compile.grammars', [
      'source.coffee'
      'source.litcoffee'
      'text.plain'
      'text.plain.null-grammar'
    ])

  describe "should open a new pane", ->
    beforeEach ->
      atom.workspaceView.attachToDom()

      waitsForPromise "fixture file to open", ->
        atom.workspace.open "coffee-compile-fixtures.coffee"

      runs ->
        atom.workspaceView.getActiveView().trigger "coffee-compile:compile"

      waitsFor "renderCompiled to be called", ->
        CoffeeCompileView::renderCompiled.callCount > 0

    it "should always split to the right", ->
      runs ->
        expect(atom.workspaceView.getPaneViews()).toHaveLength 2
        [editorPane, compiledPane] = atom.workspaceView.getPanes()

        expect(editorPane.items).toHaveLength 1

        compiled = compiledPane.getActiveItem()

    it "should have the same instance", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPanes()
        compiled = compiledPane.getActiveItem()

        expect(compiled).toBeInstanceOf(CoffeeCompileView)

    it "should have the same path as active pane", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPaneViews()
        compiled = compiledPane.getActiveItem()

        expect(compiled.getUri()).toBe atom.workspaceView.getActivePaneItem().getUri()

    it "should focus on compiled pane", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPaneViews()
        expect(compiledPane).toHaveFocus()

  describe "focus editor after compile", ->
    beforeEach ->
      atom.config.set "coffee-compile.focusEditorAfterCompile", true
      atom.workspaceView.attachToDom()

      waitsForPromise ->
        atom.workspace.open "test.coffee"

      runs ->
        atom.workspaceView.getActiveView().trigger "coffee-compile:compile"

      waitsFor ->
        CoffeeCompileView::renderCompiled.callCount > 0

    it "should focus editor when option is set", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPaneViews()
        expect(editorPane).toHaveFocus()

  describe "when the editor's grammar is not coffeescript", ->
    it "should not preview compiled js", ->
      atom.config.set "coffee-compile.grammars", []
      atom.workspaceView.attachToDom()

      waitsForPromise ->
        atom.workspace.open "coffee-compile-fixtures.coffee"

      runs ->
        spyOn(atom.workspace, "open").andCallThrough()
        atom.workspaceView.getActiveView().trigger 'markdown-preview:show'
        expect(atom.workspace.open).not.toHaveBeenCalled()
