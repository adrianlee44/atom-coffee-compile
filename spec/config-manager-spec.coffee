configManager = require '../lib/config-manager'

describe 'configManager', ->
  beforeEach ->
    atom.project.setPaths([__dirname])

  afterEach ->
    atom.config.unset('coffee-compile')
    configManager.unsetConfig()
    configManager.deactivate()

  it 'should set configFile when the file exist', ->
    configManager.initProjectConfig('coffee-compile-test.cson')

    expect(configManager.projectConfig).toBeDefined()
    expect(configManager.projectConfig.noTopLevelFunctionWrapper).toBe true

  it 'should not configFile when the file exist', ->
    configManager.initProjectConfig('coffee-compile-test-not-exist.cson')

    expect(configManager.projectConfig).toEqual({})

  describe 'after initProjectConfig', ->
    beforeEach ->
      configManager.initProjectConfig('coffee-compile-test.cson')

    it 'should get the proper setting', ->
      atom.config.set('coffee-compile.noTopLevelFunctionWrapper', false)
      expect(configManager.get('noTopLevelFunctionWrapper')).toBe true

    it 'should default to atom config', ->
      atom.config.set('coffee-compile.focusEditorAfterCompile', true)
      expect(configManager.get('focusEditorAfterCompile')).toBe true

    it 'should set the key', ->
      atom.config.set('coffee-compile.noTopLevelFunctionWrapper', true)
      configManager.set 'noTopLevelFunctionWrapper', false
      expect(configManager.get('noTopLevelFunctionWrapper')).toBe false

    it 'should emit did-change event', ->
      updatedCallback = jasmine.createSpy 'updated'
      configManager.onDidChangeKey 'noTopLevelFunctionWrapper', updatedCallback

      expect(updatedCallback).not.toHaveBeenCalled()
      configManager.set 'noTopLevelFunctionWrapper', false
      expect(updatedCallback).toHaveBeenCalled()

  describe 'removing coffee-compile.cson', ->
    beforeEach ->
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
