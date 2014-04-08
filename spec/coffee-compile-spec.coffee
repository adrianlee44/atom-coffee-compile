temp   = require "temp"
wrench = require "wrench"
path   = require "path"

CoffeeCompileView = require '../lib/coffee-compile-view'
{WorkspaceView} = require 'atom'

describe "CoffeeCompile", ->
  beforeEach ->
    fixturesPath = path.join __dirname, "fixtures"
    tempPath     = temp.mkdirSync "atom"
    wrench.copyDirSyncRecursive fixturesPath, tempPath, forceDelete: true
    atom.project.setPath tempPath

    jasmine.unspy window, "setTimeout"

    atom.workspaceView = new WorkspaceView
    atom.workspace     = atom.workspaceView.model
    spyOn(CoffeeCompileView.prototype, "renderCompiled")

    waitsForPromise ->
      atom.packages.activatePackage('coffee-compile')

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    atom.workspaceView.attachToDom()

  describe "should open a new pane", ->
    beforeEach ->
      atom.workspaceView.attachToDom()

      waitsForPromise ->
        atom.workspace.open "test.coffee"

      runs ->
        atom.workspaceView.getActiveView().trigger "coffee-compile:compile"

      waitsFor ->
        CoffeeCompileView::renderCompiled.callCount > 0

    it "should always split to the right", ->
      runs ->
        expect(atom.workspaceView.getPanes()).toHaveLength 2
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
        [editorPane, compiledPane] = atom.workspaceView.getPanes()
        compiled = compiledPane.getActiveItem()

        expect(compiled.getPath()).toBe atom.workspaceView.getActivePaneItem().getPath()

    it "should focus on compiled pane", ->
      runs ->
        [editorPane, compiledPane] = atom.workspaceView.getPanes()
        compiled = compiledPane.getActiveItem()

        expect(compiledPane).toHaveFocus()

    it "should focus editor when option is set", ->
      runs ->
        atom.config.set "coffee-compile.focusEditorAfterCompile", true
        [editorPane, compiledPane] = atom.workspaceView.getPanes()

        expect(editorPane).toHaveFocus()

  describe "when the editor's grammar is not coffeescript", ->
    it "should not preview compiled js", ->
      atom.config.set "coffee-compile.grammars", []
      atom.workspaceView.attachToDom()

      waitsForPromise ->
        atom.workspace.open "test.coffee"

      runs ->
        spyOn(atom.workspace, "open").andCallThrough()
        atom.workspaceView.getActiveView().trigger 'markdown-preview:show'
        expect(atom.workspace.open).not.toHaveBeenCalled()
