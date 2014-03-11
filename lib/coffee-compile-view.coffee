{$, $$$, EditorView, ScrollView} = require 'atom'
coffee = require 'coffee-script'
_ = require 'underscore-plus'
path = require 'path'

module.exports =
class CoffeeCompileView extends ScrollView
  @content: ->
    @div class: 'coffee-compile native-key-bindings', tabindex: -1, =>
      @div class: 'editor editor-colors', =>
        @div outlet: 'compiledCode', class: 'lang-javascript lines'

  constructor: (@filePath) ->
    super
    @bindEvents()

  destroy: ->
    @unsubscribe()

  bindEvents: ->
    @subscribe atom.syntax, 'grammar-updated', _.debounce((=> @renderCompiled()), 250)
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  setCode: (@code, @grammar) ->

  renderCompiled: ->
    try
      bare     = atom.config.get('coffee-compile.noTopLevelFunctionWrapper') or true
      literate = @grammar is "source.litcoffee"
      text     = coffee.compile @code, {bare, literate}
    catch e
      text = e.stack

    grammar = atom.syntax.selectGrammar("hello.js", text)
    @compiledCode.empty()

    for tokens in grammar.tokenizeLines(text)
      attributes = class: "line"
      @compiledCode.append(EditorView.buildLineHtml({tokens, text, attributes}))

    # Match editor styles
    @compiledCode.css
      fontSize: atom.config.get('editor.fontSize') or 12
      fontFamily: atom.config.get('editor.fontFamily')

  getTitle: -> "Compiled #{path.basename(@filePath)}"
  getUri:   -> "coffeecompile://#{@filePath}"
  getPath:  -> @filePath
