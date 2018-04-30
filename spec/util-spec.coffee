util = require '../lib/util'
fs = require 'fs'

describe "util", ->
  editor = null

  beforeEach ->
    atom.project.setPaths([__dirname])

    waitsForPromise ->
      atom.packages.activatePackage 'language-coffee-script'

    waitsForPromise ->
      atom.packages.activatePackage 'coffee-compile'

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
    beforeEach ->
      spyOn(editor, 'getText').andReturn 'hello world'

    it 'should compile bare', ->
      expected = """
      hello(world);

      """
      expect(util.compile(editor)).toBe expected

    it 'should compile with wrapper', ->
      atom.config.set('coffee-compile.noTopLevelFunctionWrapper', false)

      expected = """
      (function() {
        hello(world);

      }).call(this);

      """

      expect(util.compile(editor)).toBe expected

    it 'should compile with coffeescript v2', ->
      atom.config.set('coffee-compile.coffeescriptVersion', '2.0.2')

      expected = """
      hello(world);

      """

      expect(util.compile(editor)).toBe expected

  # Commented out since there is a bug with language-coffee-script at the moment
  # describe 'compile litcoffee', ->
  #   litcoffeeEditor = null
  #
  #   beforeEach ->
  #     waitsForPromise ->
  #       atom.packages.activatePackage('language-coffee-script')
  #
  #     waitsForPromise ->
  #       atom.workspace.open('test.litcoffee').then (o) ->
  #         litcoffeeEditor = o
  #
  #   it 'should compile literate', ->
  #     source = """
  #     This is a test
  #
  #         test = ->
  #           hello world
  #     """
  #
  #     expected = """
  #     var test;
  #
  #     test = function() {
  #       return hello(world);
  #     };
  #
  #     """
  #     spyOn(util, 'getSelectedCode').andReturn source
  #
  #     expect(util.compile(litcoffeeEditor)).toBe expected

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

  describe 'compileOrStack', ->
    it 'should return compiled text', ->
      spyOn(util, 'compile').andReturn 'console.log("just a test")'

      expect(util.compileOrStack({})).toBe('console.log("just a test")')

    it 'should use use exception stack', ->
      spyOn(util, 'compile').andCallFake ->
        throw new Error('Hi')

      expect(util.compileOrStack({})).toBeDefined()
