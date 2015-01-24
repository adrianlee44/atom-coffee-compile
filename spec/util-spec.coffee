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

      expect(util.compile('hello world')).toBe expected

    it 'should compile with wrapper', ->
      atom.config.set('coffee-compile.noTopLevelFunctionWrapper', false)

      expected = """
      hello(world);

      """

      expect(util.compile('hello world')).toBe expected

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

      expect(util.compile(source, true)).toBe expected

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

  describe 'isLiterate', ->
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-coffee-script')

    it 'should return true', ->
      waitsForPromise ->
        atom.project.open('test.litcoffee').then (o) ->
          editor = o

      runs ->
        expect(util.isLiterate(editor)).toBe true

    it 'should return false', ->
      expect(util.isLiterate(editor)).toBe false

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
