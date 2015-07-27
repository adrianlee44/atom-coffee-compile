fs = require 'fs'
fsUtil = require '../lib/fs-util'
path = require 'path'

describe "fs util", ->
  testPath = "/home/test/github/coffee-compile/lib/fs-util.coffee"

  describe "toExt", ->
    it "should convert to js extension", ->
      output = fsUtil.toExt testPath, 'js'
      expect(output).toBe "/home/test/github/coffee-compile/lib/fs-util.js"

  describe "resolvePath", ->
    beforeEach ->
      atom.project.setPaths(["/home/test/github/coffee-compile"])

    afterEach ->
      atom.config.unset('coffee-compile')

    it "should return same path", ->
      output = fsUtil.resolvePath testPath
      expect(output).toBe testPath

    it "should return an updated path", ->
      atom.config.set("coffee-compile.destination", "test/folder")

      output = fsUtil.resolvePath testPath
      expect(output).toBe "/home/test/github/coffee-compile/test/folder/lib/fs-util.coffee"

    it "should flatten path", ->
      atom.config.set("coffee-compile.flatten", true)
      output = fsUtil.resolvePath testPath
      expect(output).toBe "/home/test/github/coffee-compile/fs-util.coffee"

    it "should join cwd path", ->
      atom.config.set("coffee-compile.cwd", "lib")
      cwdTestPath = "/home/test/github/coffee-compile/lib/more/folder/fs-util.coffee"
      output = fsUtil.resolvePath cwdTestPath
      expect(output).toBe "/home/test/github/coffee-compile/more/folder/fs-util.coffee"

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
      waitsForPromise ->
        fsUtil.writeFile filePath, "test"

      runs ->
        expect(fs.existsSync(filePath)).toBe true

  describe "isPathInSrc", ->
    beforeEach ->
      atom.project.setPaths(["/home/test/github/coffee-compile"])

    afterEach ->
      atom.config.unset('coffee-compile')

    it "should return true when lib is in source", ->
      atom.config.set("coffee-compile.source", ["lib/", "src/"])

      output = fsUtil.isPathInSrc testPath
      expect(output).toBe true

    it "should return false when the file is not in the source folder", ->
      atom.config.set("coffee-compile.source", ["does-not-exist/"])

      output = fsUtil.isPathInSrc testPath
      expect(output).toBe false

    it "should return true when root is source", ->
      atom.config.set("coffee-compile.source", ["."])

      output = fsUtil.isPathInSrc testPath
      expect(output).toBe true

    it "should be relative to cwd and return true", ->
      atom.config.set("coffee-compile.cwd", "lib/")
      atom.config.set("coffee-compile.source", ["more/"])
      cwdTestPath = "/home/test/github/coffee-compile/lib/more/folder/fs-util.coffee"

      output = fsUtil.isPathInSrc cwdTestPath
      expect(output).toBe true

    it "should not be relative to cwd and return false", ->
      atom.config.set("coffee-compile.cwd", "spec")
      atom.config.set("coffee-compile.source", ["."])
      cwdTestPath = "/home/test/github/coffee-compile/lib/more/folder/fs-util.coffee"

      output = fsUtil.isPathInSrc cwdTestPath
      expect(output).toBe false
