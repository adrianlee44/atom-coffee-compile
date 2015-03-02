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

  it "should compile the whole file and display compiled js", ->
    spyOn CoffeeCompileEditor.prototype, "renderCompiled"

    compiled = new CoffeeCompileEditor {sourceEditor: editor}

    expect(CoffeeCompileEditor.prototype.renderCompiled).toHaveBeenCalled()
