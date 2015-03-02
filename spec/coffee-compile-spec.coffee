CoffeeCompileEditor = require '../lib/coffee-compile-editor'
util = require '../lib/util'

describe 'CoffeeCompile', ->
  editor = null
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView atom.workspace
    jasmine.attachToDOM workspaceElement

    waitsForPromise 'language-coffee-script to activate', ->
      atom.packages.activatePackage 'language-coffee-script'

    waitsForPromise ->
      atom.packages.activatePackage 'coffee-compile'

    waitsForPromise ->
      atom.workspace.open('coffee-compile-fixtures.coffee').then (o) ->
        editor = o

    runs ->
      atom.config.set 'coffee-compile.grammars', [
        'source.coffee'
        'source.litcoffee'
        'text.plain'
        'text.plain.null-grammar'
      ]

      spyOn(CoffeeCompileEditor.prototype, 'renderCompiled').andCallThrough()

  describe 'compile on save', ->
    beforeEach ->
      spyOn util, 'compileToFile'

    it 'should call util.compileToFile', ->
      atom.config.set 'coffee-compile.compileOnSave', true

      runs ->
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor ->
        util.compileToFile.callCount > 0

      runs ->
        expect(util.compileToFile).toHaveBeenCalled()

    it 'should not call util.compileToFile', ->
      atom.config.set 'coffee-compile.compileOnSave', false

      runs ->
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'
        expect(util.compileToFile).not.toHaveBeenCalled()

  describe 'open a new pane', ->
    beforeEach ->
      runs ->
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'renderCompiled to be called', ->
        CoffeeCompileEditor::renderCompiled.callCount > 0

    it 'should always split to the right', ->
      runs ->
        expect(atom.workspace.getPanes()).toHaveLength 2
        [editorPane, compiledPane] = atom.workspace.getPanes()

        expect(editorPane.items).toHaveLength 1

        compiled = compiledPane.getActiveItem()

    it 'should focus on compiled pane', ->
      runs ->
        [editorPane, compiledPane] = atom.workspace.getPanes()
        expect(compiledPane.isActive()).toBe(true)

  describe 'focus editor after compile', ->
    callback = null

    beforeEach ->
      callback = jasmine.createSpy 'pane'

      atom.config.set 'coffee-compile.focusEditorAfterCompile', true

      atom.workspace.onDidOpen callback

    it 'should focus editor when option is set', ->
      runs ->
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor ->
        callback.callCount > 0

      runs ->
        [editorPane, compiledPane] = atom.workspace.getPanes()
        expect(editorPane.isActive()).toBe(true)

  describe "when the editor's grammar is not coffeescript", ->
    it 'should not preview compiled js', ->
      atom.config.set 'coffee-compile.grammars', []

      waitsForPromise ->
        atom.workspace.open 'coffee-compile-fixtures.coffee'

      runs ->
        spyOn console, 'warn'
        spyOn(atom.workspace, 'open').andCallThrough()

        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

        expect(console.warn).toHaveBeenCalled()
        expect(atom.workspace.open).not.toHaveBeenCalled()
