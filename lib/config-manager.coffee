cson = require 'season'
{File, Emitter, CompositeDisposable} = require 'atom'

class ConfigManager
  @filename = 'coffee-compile.cson'
  @configPrefix = 'coffee-compile.'

  constructor: ->
    @configDisposables = new CompositeDisposable
    @emitter           = new Emitter
    @projectConfig     = {}

  initProjectConfig: (filename = ConfigManager.filename) ->
    if atom.config.get('coffee-compile.enableProjectConfig')
      configPath = atom.project.resolvePath(filename)

      return unless configPath

      if @configDisposables?
        @configDisposables.dispose()
      @configDisposables = new CompositeDisposable

      @configFile = new File(configPath)

      if @configFile.existsSync()
        @setConfigFromFile()

        @configDisposables.add @configFile.onDidChange => @reloadProjectConfig()
        @configDisposables.add @configFile.onDidDelete =>
          @upsetConfig()
          @configDisposables.dispose()
          @configFile = null

  deactivate: ->
    if @configDisposables?
      @configDisposables.dispose()
      @configDisposables = null
    @configFile = null

  setConfigFromFile: ->
    @projectConfig = cson.readFileSync @configFile.getPath()

  unsetConfig: ->
    @projectConfig = {}

  reloadProjectConfig: ->
    @setConfigFromFile()
    @emitter.emit 'did-change'

  get: (key) ->
    if @projectConfig[key]?
      @projectConfig[key]
    else
      atom.config.get("#{ConfigManager.configPrefix}#{key}")

  set: (key, value) ->
    @projectConfig[key] = value
    @emitter.emit 'did-change'

  observe: (key, callback) ->
    disposable = new CompositeDisposable

    disposable.add atom.config.observe("#{ConfigManager.configPrefix}#{key}", callback)
    disposable.add @onDidChangeKey(key, callback)

    disposable

  onDidChangeKey: (key, callback) ->
    oldValue = @projectConfig[key]
    @emitter.on 'did-change', =>
      newValue = @projectConfig[key]
      if @projectConfig[key]? and oldValue isnt newValue
        oldValue = newValue
        callback newValue

module.exports = new ConfigManager()
