CoffeeCompileView = require '../lib/coffee-compile-view'
{WorkspaceView} = require 'atom'
fs = require 'fs'

describe "CoffeeCompileView", ->
  compiled = null
  editor   = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace     = atom.workspaceView.model

    waitsForPromise ->
      atom.project.open('test.coffee').then (o) ->
        editor = o

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

  describe "renderCompiled", ->
    it "should compile the whole file and display compiled js", ->
      spyOn CoffeeCompileView.prototype, "renderCompiled"

      compiled = new CoffeeCompileView {sourceEditor: editor}

      expect(CoffeeCompileView.prototype.renderCompiled).toHaveBeenCalled()
