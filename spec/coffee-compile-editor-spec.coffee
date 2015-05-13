CoffeeCompileEditor = require '../lib/coffee-compile-editor'
fs = require 'fs'

describe "CoffeeCompileEditor", ->
  compiled = null
  editor   = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    waitsForPromise ->
      atom.packages.activatePackage 'coffee-compile'

    waitsForPromise ->
      atom.project.open('test.coffee').then (o) ->
        editor = o

  it "should compile and display compiled js with no errors", ->
    spyOn CoffeeCompileEditor.prototype, "renderCompiled"

    compiled = new CoffeeCompileEditor {sourceEditor: editor}
    compiled.renderCompiled()

    expect(CoffeeCompileEditor.prototype.renderCompiled).toHaveBeenCalled()
