CoffeeCompileView = require '../lib/coffee-compile-view'
{WorkspaceView} = require 'atom'
fs = require 'fs'
util = require '../lib/util'

describe "CoffeeCompile", ->
  editor = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace     = atom.workspaceView.model

    waitsForPromise "language-coffee-script to activate", ->
      atom.packages.activatePackage('language-coffee-script')

    waitsForPromise ->
      atom.packages.activatePackage('coffee-compile')

    waitsForPromise ->
      atom.workspace.open('coffee-compile-fixtures.coffee').then (o) ->
        editor = o

    runs ->
      atom.workspaceView.attachToDom()

      spyOn(CoffeeCompileView.prototype, "renderCompiled").andCallThrough()

  describe "compile on save", ->
    beforeEach ->
      spyOn util, "compileToFile"

      waitsForPromise "coffee-compile package to activate", ->
        atom.packages.activatePackage('coffee-compile')

      waitsForPromise "fixture file to open", ->
        atom.workspace.open "coffee-compile-fixtures.coffee"

    it "should call util.compileToFile", ->
      atom.config.set "coffee-compile.compileOnSave", true

      runs ->
        atom.workspaceView.getActiveView().trigger "coffee-compile:compile"

      waitsFor ->
        util.compileToFile.callCount > 0

      runs ->
        expect(util.compileToFile).toHaveBeenCalled()

    it "should not call util.compileToFile", ->
      atom.config.set "coffee-compile.compileOnSave", false

      runs ->
        atom.workspaceView.getActiveView().trigger "coffee-compile:compile"
        expect(util.compileToFile).not.toHaveBeenCalled()

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

    it "should focus on compiled pane", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPaneViews()
        expect(compiledPane).toHaveFocus()

  xdescribe "focus editor after compile", ->
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

    xit "should focus editor when option is set", ->
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
