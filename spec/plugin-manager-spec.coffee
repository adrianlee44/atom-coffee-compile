pluginManager = require '../lib/plugin-manager'
coffeeProvider = require '../lib/coffee-provider'
{Disposable} = require 'atom'

describe "pluginManager", ->
  beforeEach ->
    # Reset plugin manager for every test
    pluginManager.plugins.length = 0
    pluginManager.languages = {}

  describe "register", ->
    it "should register successfully and return a Disposable", ->
      output = pluginManager.register coffeeProvider

      expect(output instanceof Disposable).toBe true

    it "should push functions to all 3 compilers", ->
      preCompile = (code) -> return code
      compile = (code) -> return code
      postCompile = (code) -> return code

      pluginManager.register
        id: 'some-test'
        selector: ['source.invalid']
        preCompile: preCompile
        compile: compile
        postCompile: postCompile

      language = pluginManager.languages['source.invalid']
      expect(language.preCompilers[0]).toBe preCompile
      expect(language.compilers[0]).toBe compile
      expect(language.postCompilers[0]).toBe postCompile

    it "should not push when function does not exist", ->
      preCompile = (code) -> return code

      pluginManager.register
        id: 'some-test'
        selector: ['source.invalid']
        preCompile: preCompile

      language = pluginManager.languages['source.invalid']
      expect(language.preCompilers[0]).toBe preCompile
      expect(language.compilers[0]).toBeUndefined()
      expect(language.postCompilers[0]).toBeUndefined()

    it "should use the same function for multiple languages", ->
      preCompile = (code) -> return code

      pluginManager.register
        id: 'some-test'
        selector: ['source.invalid', 'source.valid']
        preCompile: preCompile

      language = pluginManager.languages['source.invalid']
      expect(language.preCompilers[0]).toBe preCompile

      language2 = pluginManager.languages['source.valid']
      expect(language2.preCompilers[0]).toBe preCompile

    it "should warn when package is already activated", ->
      pluginManager.register coffeeProvider

      spyOn console, 'warn'

      pluginManager.register coffeeProvider

      expect(console.warn).toHaveBeenCalled()

    it "should pushed to plugins array", ->
      pluginManager.register coffeeProvider

      expect(pluginManager.plugins[0]).toBe coffeeProvider

  describe "unregister", ->
    it "should not unregister a non-registered plugin", ->
      somePlugin =
        id: 'some-plugin'
        selector: ['source.invalid']
        preCompile: (code) -> return code

      pluginManager.register coffeeProvider

      expect(pluginManager.plugins.length).toBe 1
      expect(pluginManager.languages['source.coffee']).toBeDefined()

      pluginManager.unregister somePlugin

      expect(pluginManager.plugins.length).toBe 1
      expect(pluginManager.languages['source.coffee']).toBeDefined()

    it "should unregister correctly", ->
      pluginManager.register coffeeProvider

      expect(pluginManager.plugins.length).toBe 1
      expect(pluginManager.languages['source.coffee']).toBeDefined()

      pluginManager.unregister coffeeProvider

      expect(pluginManager.plugins.length).toBe 0

      language = pluginManager.languages['source.coffee']
      expect(language.preCompilers.length).toBe 0
      expect(language.compilers.length).toBe 0
      expect(language.postCompilers.length).toBe 0

  describe "getLanguageByScope", ->
    it "should get language scope", ->
      pluginManager.register coffeeProvider

      output = pluginManager.getLanguageByScope "source.coffee"
      expect(output).toBeDefined()

    it "should not get anything", ->
      pluginManager.register coffeeProvider

      output = pluginManager.getLanguageByScope "source.css"
      expect(output).toBeUndefined()

  describe "isScopeSupported", ->
    it "should get language scope", ->
      pluginManager.register coffeeProvider

      output = pluginManager.isScopeSupported "source.coffee"
      expect(output).toBe true

    it "should not get anything", ->
      pluginManager.register coffeeProvider

      output = pluginManager.isScopeSupported "source.css"
      expect(output).toBe false
