CoffeeCompileView = require '../lib/coffee-compile-view'
{WorkspaceView} = require 'atom'

describe "CoffeeCompile", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace     = atom.workspaceView.model

    waitsForPromise "language-coffee-script to activate", ->
      atom.packages.activatePackage('language-coffee-script')

    atom.config.set('coffee-compile.grammars', [
      'source.coffee'
      'source.litcoffee'
      'text.plain'
      'text.plain.null-grammar'
    ])

    atom.workspaceView.attachToDom()

    spyOn(CoffeeCompileView.prototype, "renderCompiled").andCallThrough()

  describe "compile on save without preview", ->
    beforeEach ->
      spyOn CoffeeCompileView, "saveCompiled"

    it "should call savedCompiled", ->
      atom.config.set("coffee-compile.compileOnSaveWithoutPreview", true)

      waitsForPromise "coffee-compile package to activate", ->
        atom.packages.activatePackage('coffee-compile')

      waitsForPromise "fixture file to open", ->
        atom.workspace.open "coffee-compile-fixtures.coffee"

      runs ->
        atom.workspaceView.trigger "core:save"
        expect(CoffeeCompileView.saveCompiled).toHaveBeenCalled()

    it "should not call saveCompiled when option is disabled", ->
      atom.config.set("coffee-compile.compileOnSaveWithoutPreview", false)

      waitsForPromise "coffee-compile package to activate", ->
        atom.packages.activatePackage('coffee-compile')

      waitsForPromise "fixture file to open", ->
        atom.workspace.open "coffee-compile-fixtures.coffee"

      runs ->
        atom.workspaceView.trigger "core:save"
        expect(CoffeeCompileView.saveCompiled).not.toHaveBeenCalled()

  describe "compile on save", ->
    beforeEach ->
      spyOn CoffeeCompileView, "saveCompiled"

      waitsForPromise "coffee-compile package to activate", ->
        atom.packages.activatePackage('coffee-compile')

      waitsForPromise "fixture file to open", ->
        atom.workspace.open "coffee-compile-fixtures.coffee"

    it "should call savedCompiled", ->
      atom.config.set "coffee-compile.compileOnSave", true

      runs ->
        atom.workspaceView.getActiveView().trigger "coffee-compile:compile"

      waitsFor ->
        CoffeeCompileView::renderCompiled.callCount > 0

      runs ->
        expect(CoffeeCompileView.saveCompiled).toHaveBeenCalled()

    it "should not call savedCompiled", ->
      atom.config.set "coffee-compile.compileOnSave", false

      runs ->
        atom.workspaceView.getActiveView().trigger "coffee-compile:compile"

      waitsFor ->
        CoffeeCompileView::renderCompiled.callCount > 0

      runs ->
        expect(CoffeeCompileView.saveCompiled).not.toHaveBeenCalled()

  describe "open a new pane", ->
    beforeEach ->
      waitsForPromise "coffee-compile package to activate", ->
        atom.packages.activatePackage('coffee-compile')

      waitsForPromise "fixture file to open", ->
        atom.workspace.open "coffee-compile-fixtures.coffee"

      runs ->
        atom.workspaceView.getActiveView().trigger "coffee-compile:compile"

      waitsFor "renderCompiled to be called", ->
        CoffeeCompileView::renderCompiled.callCount > 0

    it "should always split to the right", ->
      runs ->
        expect(atom.workspaceView.getPaneViews()).toHaveLength 2
        [editorPane, compiledPane] = atom.workspaceView.getPaneViews()

        expect(editorPane.items).toHaveLength 1

        compiled = compiledPane.getActiveItem()

    it "should have the same instance", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPaneViews()
        compiled = compiledPane.getActiveItem()

        expect(compiled).toBeInstanceOf(CoffeeCompileView)

    it "should have the same path as active pane", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPaneViews()
        compiled = compiledPane.getActiveItem()

        expect(compiled.getUri()).toBe atom.workspace.getActivePaneItem().getUri()

    it "should focus on compiled pane", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPaneViews()
        expect(compiledPane).toHaveFocus()

  describe "focus editor after compile", ->
    beforeEach ->
      atom.config.set "coffee-compile.focusEditorAfterCompile", true

      waitsForPromise "coffee-compile package to activate", ->
        atom.packages.activatePackage('coffee-compile')

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

      waitsForPromise "coffee-compile package to activate", ->
        atom.packages.activatePackage('coffee-compile')

      waitsForPromise ->
        atom.workspace.open "coffee-compile-fixtures.coffee"

      runs ->
        spyOn(atom.workspace, "open").andCallThrough()
        atom.workspaceView.getActiveView().trigger 'markdown-preview:show'
        expect(atom.workspace.open).not.toHaveBeenCalled()
