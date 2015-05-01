util = require '../lib/util'
fs = require 'fs'

describe "util", ->
  editor = null

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open('coffee-compile-fixtures.coffee').then (o) ->
        editor = o

  describe 'getTextEditorById', ->
    it 'should find the right editor', ->
      id = editor.id
      expect(util.getTextEditorById id).toBe editor

    it 'should not find the editor', ->
      id = editor.id + 1
      expect(util.getTextEditorById id).toBe null

  describe 'compile', ->
    it 'should compile bare', ->
      expected = """
      hello(world);

      """

      expect(util.compile('hello world', editor)).toBe expected

    it 'should compile with wrapper', ->
      atom.config.set('coffee-compile.noTopLevelFunctionWrapper', false)

      expected = """
      (function() {
        hello(world);

      }).call(this);

      """

      expect(util.compile('hello world', editor)).toBe expected

  describe 'compile litcoffee', ->
    litcoffeeEditor = null

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

      waitsForPromise ->
        atom.workspace.open('test.litcoffee').then (o) ->
          litcoffeeEditor = o

    it 'should compile literate', ->
      source = """
      This is a test

          test = ->
            hello world
      """

      expected = """
      var test;

      test = function() {
        return hello(world);
      };

      """

      expect(util.compile(source, litcoffeeEditor)).toBe expected

  describe 'getSelectedCode', ->
    text = """
    # This is a test
    module.exports =
      hello: ->
        console.log 'leave me alone'
    """

    beforeEach ->
      editor.setText text

    it 'should return all text in editor', ->
      expect(util.getSelectedCode(editor)).toBe text

    it 'should return selected text in editor', ->
      editor.setSelectedBufferRange([[0, 0], [0, 16]])

      expect(util.getSelectedCode(editor)).toBe "# This is a test"

  describe 'compileToFile', ->
    filePath = null

    beforeEach ->
      filePath = editor.getPath()
      filePath = filePath.replace ".coffee", ".js"

    afterEach ->
      fs.unlink(filePath) if fs.existsSync(filePath)

    it 'should create a js file', ->
      callback = jasmine.createSpy 'save'

      runs ->
        util.compileToFile editor, callback

      waitsFor ->
        callback.callCount > 0

      runs ->
        expect(fs.existsSync(filePath)).toBe true
