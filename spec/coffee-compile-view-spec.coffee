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
    beforeEach ->
      runs ->
        compiled = new CoffeeCompileView {sourceEditor: editor}

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

      atom.config.set 'coffee-compile.compileOnSave', true

      compiled = new CoffeeCompileView {sourceEditor: editor}

    afterEach ->
      fs.unlink(filePath) if fs.existsSync(filePath)

      coffeeFilePath = editor.getPath()
      fs.unlink(coffeeFilePath) if fs.existsSync(coffeeFilePath)

    it "should compile and create a js when saving", ->
      spyOn CoffeeCompileView, "saveCompiled"

      editor.save()

      expect(CoffeeCompileView.saveCompiled).toHaveBeenCalled()

    it "should also recompile the preview pane", ->
      spyOn compiled, "renderCompiled"

      editor.save()

      expect(compiled.renderCompiled).toHaveBeenCalled()

    it "should compile and create a js file", ->
      callback = jasmine.createSpy 'save'

      runs ->
        CoffeeCompileView.saveCompiled editor, callback

      waitsFor "Compile on save", ->
        callback.callCount > 0

      runs ->
        expect(fs.existsSync(filePath)).toBeTruthy()
