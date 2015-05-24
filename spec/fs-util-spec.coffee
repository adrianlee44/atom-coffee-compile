fs = require 'fs'
fsUtil = require '../lib/fs-util'
path = require 'path'

describe "fs util", ->
  testPath = "/home/test/github/coffee-compile/lib/fs-util.coffee"

  describe "toExt", ->
    it "should convert to js extension", ->
      output = fsUtil.toExt testPath, 'js'
      expect(output, "/home/test/github/coffee-compile/lib/fs-util.js")

  describe "resolvePath", ->
    beforeEach ->
      atom.project.setPaths(["/home/test/github/coffee-compile"])

    it "should return same path", ->
      output = fsUtil.resolvePath testPath
      expect(output, testPath)

    it "should return an updated path", ->
      atom.config.set("coffee-compile.destination", "test/folder")

      output = fsUtil.resolvePath testPath
      expect(output, "/home/test/github/coffee-compile/test/folder/lib/fs-util.js")

    it "should flatten path", ->
      atom.config.set("coffee-compile.flatten", true)
      output = fsUtil.resolvePath testPath
      expect(output, "/home/test/github/coffee-compile/fs-util.js")

  describe "writeFile", ->
    editor = null
    filePath = null

    beforeEach ->
      waitsForPromise ->
        atom.workspace.open('coffee-compile-fixtures.coffee').then (o) ->
          editor = o

      runs ->
        filePath = editor.getPath()
        folder = path.dirname filePath
        filePath = path.join folder, "test/lib", "coffee-compile-fixtures.js"

    afterEach ->
      fs.unlink(filePath) if fs.existsSync(filePath)

    it "should make folders and create a js file", ->
      callback = jasmine.createSpy "write"

      runs ->
        fsUtil.writeFile filePath, "test", callback

      waitsFor ->
        callback.callCount > 0

      runs ->
        expect(fs.existsSync(filePath)).toBe true
