{$, $$$, EditorView, ScrollView} = require 'atom'
coffee = require 'coffee-script'
_ = require 'underscore-plus'

module.exports =
class CoffeeCompileView extends ScrollView
  @content: ->
    @div class: 'coffee-compile native-key-bindings', tabindex: -1, =>
      @pre class: 'editor-colors', =>
        @code outlet: 'compiledCode', class: 'lang-javascript'

  constructor: (@filePath) ->
    super
    @bindEvents()

  destroy: ->
    @unsubscribe()

  bindEvents: ->
    @subscribe atom.syntax, 'grammar-updated', _.debounce((=> @renderCompiled()), 250)
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  setCode: (@code) ->

  renderCompiled: ->
    try
      text = coffee.compile @code, bare: true
    catch e
      text = e.stack

    grammar = atom.syntax.selectGrammar("hello.js", text)
    @compiledCode.empty()

    for tokens in grammar.tokenizeLines(text)
      @compiledCode.append(EditorView.buildLineHtml({tokens, text}))

    # Match editor styles
    @compiledCode.css
      fontSize: atom.config.get('editor.fontSize') or 12
      fontFamily: atom.config.get('editor.fontFamily')

  getTitle: => "Compiled #{@filePath}"
