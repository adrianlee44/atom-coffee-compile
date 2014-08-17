CoffeeCompileView = require '../lib/coffee-compile-view'
{WorkspaceView} = require 'atom'
fs = require 'fs'

describe "CoffeeCompileView", ->
  compiled = null
  editor   = null

  beforeEach ->
    atom.config.set 'core.useReactEditor', false

    atom.workspaceView = new WorkspaceView
    atom.workspace     = atom.workspaceView.model

    waitsForPromise ->
      atom.project.open('test.coffee').then (o) ->
        editor = o

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    runs ->
      compiled = new CoffeeCompileView {sourceEditor: editor}

  describe "renderCompiled", ->
    it "should compile the whole file and display compiled js", ->
      spyOn compiled, "renderCompiled"

      runs ->
        compiled.renderCompiled()

      waitsFor "Coffeescript should be compiled", ->
        compiled.renderCompiled.callCount > 0

      runs ->
        expect(compiled.scrollView).toExist()

  describe "saveCompiled", ->
    filePath = null
    beforeEach ->
      filePath = editor.getPath()
      filePath = filePath.replace ".coffee", ".js"

    afterEach ->
      fs.unlink(filePath) if fs.existsSync(filePath)

    it "should compile and create a js file", ->
      callback = jasmine.createSpy 'save'

      runs ->
        compiled.saveCompiled callback

      waitsFor "Compile on save", ->
        callback.callCount > 0

      runs ->
        expect(fs.existsSync(filePath)).toBeTruthy()
