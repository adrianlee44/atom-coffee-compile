cson = require 'season'
{File, Emitter, CompositeDisposable} = require 'atom'

class ConfigManager
  @filename = 'coffee-compile.cson'
  @configPrefix = 'coffee-compile.'

  constructor: ->
    @configDisposables = new CompositeDisposable
    @emitter           = new Emitter
    @projectConfig     = {}
    @hasConfigFile     = false

  initProjectConfig: (filename = ConfigManager.filename) ->
    configPath = atom.project.resolvePath(filename)

    return unless configPath

    if @configDisposables?
      @configDisposables.dispose()
    @configDisposables = new CompositeDisposable

    @configFile = new File(configPath)

    if @hasConfigFile = @configFile.existsSync()
      @setConfigFromFile()

      @configDisposables.add @configFile.onDidChange => @reloadProjectConfig()
      @configDisposables.add @configFile.onDidDelete =>
        @unsetConfig()
        @configDisposables.dispose()
        @configFile = null
        @hasConfigFile = false

  deactivate: ->
    if @configDisposables?
      @configDisposables.dispose()
      @configDisposables = null
    @configFile = null

  setConfigFromFile: ->
    @projectConfig = cson.readFileSync(@configFile.getPath()) or {}

  unsetConfig: ->
    @projectConfig = {}
    @emitter.emit 'did-change'

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

    # Add listener for Atom configuration changes
    disposable.add atom.config.observe "#{ConfigManager.configPrefix}#{key}", =>
      callback @get(key)
    # Add listener for project-based configuration changes
    disposable.add @onDidChangeKey(key, callback)

    disposable

  onDidChangeKey: (key, callback) ->
    oldValue = @projectConfig[key]
    @emitter.on 'did-change', =>
      newValue = @projectConfig[key]
      if oldValue isnt newValue
        oldValue = newValue
        callback @get(key)

module.exports = new ConfigManager()
