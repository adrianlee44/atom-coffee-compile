util = require '../lib/util'

describe 'CoffeeCompile', ->
  editor = null
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView atom.workspace
    jasmine.attachToDOM workspaceElement

    atom.project.setPaths([__dirname])

    waitsForPromise 'language-coffee-script to activate', ->
      atom.packages.activatePackage 'language-coffee-script'

    waitsForPromise ->
      atom.packages.activatePackage 'coffee-compile'

    waitsForPromise ->
      atom.workspace.open('coffee-compile-fixtures.coffee').then (o) ->
        editor = o

    runs ->
      spyOn(util, 'compileOrStack').andCallThrough()

  describe 'open a new pane with default value', ->
    beforeEach ->
      runs ->
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'compileOrStack to be called', ->
        util.compileOrStack.callCount > 0

    it 'should always split to the right', ->
      runs ->
        expect(atom.workspace.getActivePaneContainer().paneContainer.getRoot().getOrientation()).toBe 'horizontal'

        [editorPane, compiledPane] = atom.workspace.getCenter().getPanes()

        expect(editorPane.items).toHaveLength 1

    it 'should focus on compiled pane', ->
      runs ->
        [editorPane, compiledPane] = atom.workspace.getCenter().getPanes()
        expect(compiledPane.isActive()).toBe(true)

  describe 'open a new pane with config', ->
    it 'should split to the left', ->
      runs ->
        atom.config.set('coffee-compile.split', 'Left')
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'compileOrStack to be called', ->
        util.compileOrStack.callCount > 0

      runs ->
        expect(atom.workspace.getActivePaneContainer().paneContainer.getRoot().getOrientation()).toBe 'horizontal'

        expect(atom.workspace.getCenter().getPanes()).toHaveLength 2
        [compiledPane, editorPane] = atom.workspace.getCenter().getPanes()

        expect(editorPane.items).toHaveLength 1
        expect(editorPane.items[0]).toBe editor

    it 'should split to the bottom', ->
      runs ->
        atom.config.set('coffee-compile.split', 'Down')
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'compileOrStack to be called', ->
        util.compileOrStack.callCount > 0

      runs ->
        expect(atom.workspace.getActivePaneContainer().paneContainer.getRoot().getOrientation()).toBe 'vertical'
        expect(atom.workspace.getCenter().getPanes()).toHaveLength 2
        [editorPane, compiledPane] = atom.workspace.getCenter().getPanes()

        expect(editorPane.items).toHaveLength 1
        expect(editorPane.items[0]).toBe editor

    it 'should split to the up', ->
      runs ->
        atom.config.set('coffee-compile.split', 'Up')
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'compileOrStack to be called', ->
        util.compileOrStack.callCount > 0

      runs ->
        expect(atom.workspace.getActivePaneContainer().paneContainer.getRoot().getOrientation()).toBe 'vertical'
        expect(atom.workspace.getCenter().getPanes()).toHaveLength 2
        [compiledPane, editorPane] = atom.workspace.getCenter().getPanes()

        expect(editorPane.items).toHaveLength 1
        expect(editorPane.items[0]).toBe editor

  describe 'focus editor after compile', ->
    callback = null

    beforeEach ->
      callback = jasmine.createSpy 'pane'

      atom.config.set 'coffee-compile.focusEditorAfterCompile', true

      atom.workspace.onDidOpen callback

    it 'should focus editor when option is set', ->
      originalPane = atom.workspace.getActivePane()

      runs ->
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor ->
        callback.callCount > 0

      runs ->
        expect(atom.workspace.getActivePane()).toBe(originalPane)
