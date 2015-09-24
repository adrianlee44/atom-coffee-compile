configManager = require '../lib/config-manager'

describe 'configManager', ->
  afterEach ->
    atom.config.unset('coffee-compile')
    configManager.unsetConfig()
    configManager.deactivate()

  it 'should not set configFile when enableProjectConfig is false', ->
    atom.config.set('coffee-compile.enableProjectConfig', false)
    configManager.initProjectConfig('spec/coffee-compile-test.cson')

    expect(configManager.configFile).toBeUndefined()
    expect(configManager.projectConfig).toEqual {}

  it 'should set configFile when enableProjectConfig is true', ->
    atom.config.set('coffee-compile.enableProjectConfig', true)
    configManager.initProjectConfig('coffee-compile-test.cson')

    expect(configManager.configFile).toBeDefined()
    expect(configManager.configFile.getBaseName()).toBe 'coffee-compile-test.cson'

  describe 'after initProjectConfig', ->
    beforeEach ->
      atom.config.set('coffee-compile.enableProjectConfig', true)
      configManager.initProjectConfig('coffee-compile-test.cson')

    it 'should get the proper setting', ->
      atom.config.set('coffee-compile.compileOnSave', false)
      expect(configManager.get('compileOnSave')).toBe true

    it 'should default to atom config', ->
      atom.config.set('coffee-compile.flatten', true)
      expect(configManager.get('flatten')).toBe true

    it 'should set the key', ->
      atom.config.set('coffee-compile.flatten', true)
      configManager.set 'flatten', false
      expect(configManager.get('flatten')).toBe false

    it 'should emit did-change event', ->
      updatedCallback = jasmine.createSpy 'updated'
      configManager.onDidChangeKey 'flatten', updatedCallback

      expect(updatedCallback).not.toHaveBeenCalled()
      configManager.set 'flatten', true
      expect(updatedCallback).toHaveBeenCalled()

  describe 'removing coffee-compile.cson', ->
    beforeEach ->
      atom.config.set('coffee-compile.enableProjectConfig', true)
      configManager.initProjectConfig('coffee-compile-test.cson')

    it 'should unset the project config', ->
      observe = jasmine.createSpy('observe')
      configManager.observe 'cwd', observe

      didChange = jasmine.createSpy('did-change')

      configFile = configManager.configFile
      configManager.emitter.on 'did-change', didChange
      configFile.emitter.emit 'did-delete'

      expect(configManager.projectConfig).toEqual {}
      expect(didChange).toHaveBeenCalled()
      expect(observe).toHaveBeenCalled()
