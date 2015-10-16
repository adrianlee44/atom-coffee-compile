{Disposable} = require 'atom'

###
Provider sample:
  id: 'coffee-compile'
  selector: ['source.coffee']
  preCompile: (code) ->
  compile: (code) ->
  postCompile: (code) ->
###

class PluginManager
  constructor: ->
    @plugins   = []
    @languages = {}

  register: (plugin) ->
    if @isPluginRegistered(plugin)
      console.warn "#{plugin.id} has already been activated"
      return

    for selector in plugin.selector
      @languages[selector] ?=
        preCompilers:  []
        compilers:     []
        postCompilers: []
        compiledScope: plugin.compiledScope
      language = @languages[selector]

      if plugin.preCompile? and typeof plugin.preCompile is "function"
        language.preCompilers.push plugin.preCompile

      if plugin.compile? and typeof plugin.compile is "function"
        language.compilers.push plugin.compile

      if plugin.postCompile and typeof plugin.postCompile is "function"
        language.postCompilers.push plugin.postCompile

    @plugins.push plugin

    # Unregister plugin from pluginManager
    return new Disposable => @unregister plugin

  unregister: (plugin) ->
    index = @plugins.indexOf plugin

    if index > -1
      for selector in plugin.selector
        language = @languages[selector]

        if plugin.preCompile? and typeof plugin.preCompile is "function"
          preCompilerIndex = language.preCompilers.indexOf plugin.preCompile
          language.preCompilers.splice preCompilerIndex, 1

        if plugin.compile? and typeof plugin.compile is "function"
          compilerIndex = language.compilers.indexOf plugin.compile
          language.compilers.splice compilerIndex, 1

        if plugin.postCompile? and typeof plugin.postCompile is "function"
          postCompilerIndex = language.postCompilers.indexOf plugin.postCompile
          language.postCompilers.splice postCompilerIndex, 1

      @plugins.splice index, 1

  ###
  @param {String} scope Language scope
  @returns {Object} Language configuration
  ###
  getLanguageByScope: (scope) ->
    return @languages[scope]

  ###
  @param {String} scope Language scope
  @returns {Boolean}
  ###
  isScopeSupported: (scope) ->
    return @languages[scope]?

  ###
  @param {String} scope Language scope
  @returns {Boolean}
  ###
  isPlainText: (scope) ->
    return scope.indexOf('text.plain') > -1 or scope.indexOf('null-grammar') > -1

  ###
  @param {Editor} editor
  @param {Boolean} isSaveCompile
  @returns {Boolean}
  ###
  isEditorLanguageSupported: (editor, isSaveCompile = false) ->
    scopeName = editor.getGrammar().scopeName
    
    # Do not try to compile and save plain text files
    shouldSaveCompile = !isSaveCompile or (isSaveCompile and not @isPlainText(scopeName))

    return @isScopeSupported(scopeName) and shouldSaveCompile

  ###
  @param {Editor} editor
  @returns {String}
  ###
  getCompiledScopeByEditor: (editor) ->
    return @languages[editor.getGrammar().scopeName]?.compiledScope or ''

  ###
  @param {Object} plugin
  @return {Boolean}
  ###
  isPluginRegistered: (plugin) ->
    @plugins.indexOf(plugin) isnt -1

module.exports = new PluginManager()
