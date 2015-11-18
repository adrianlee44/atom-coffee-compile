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

  describe 'compile on save without preview', ->
    beforeEach ->
      spyOn util, 'compileToFile'

    describe 'when compileOnSaveWithoutPreview = true', ->
      beforeEach ->
        atom.config.set 'coffee-compile.compileOnSaveWithoutPreview', true

      it 'should call util.compileToFile on editor save', ->
        runs ->
          editor.save()

        waitsFor ->
          util.compileToFile.callCount > 0

        runs ->
          expect(util.compileToFile).toHaveBeenCalled()

      it 'should call util.compileToFile on save command', ->
        runs ->
          atom.commands.dispatch workspaceElement, 'core:save'

        waitsFor ->
          util.compileToFile.callCount > 0

        runs ->
          expect(util.compileToFile).toHaveBeenCalled()


    describe 'when compileOnSaveWithoutPreview = false', ->
      beforeEach ->
        atom.config.set 'coffee-compile.compileOnSaveWithoutPreview', true
        atom.config.set 'coffee-compile.compileOnSaveWithoutPreview', false

      it 'should not call util.compileToFile on editor save', ->
        runs ->
          editor.save()
          expect(util.compileToFile).not.toHaveBeenCalled()

      it 'should not call util.compileToFile on save command', ->
        runs ->
          atom.commands.dispatch workspaceElement, 'core:save'
          expect(util.compileToFile).not.toHaveBeenCalled()

  describe 'open a new pane with default value', ->
    beforeEach ->
      runs ->
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'compileOrStack to be called', ->
        util.compileOrStack.callCount > 0

    it 'should always split to the right', ->
      runs ->
        expect(atom.workspace.paneContainer.root.orientation).toBe 'horizontal'
        expect(atom.workspace.getPanes()).toHaveLength 2
        [editorPane, compiledPane] = atom.workspace.getPanes()

        expect(editorPane.items).toHaveLength 1

    it 'should focus on compiled pane', ->
      runs ->
        [editorPane, compiledPane] = atom.workspace.getPanes()
        expect(compiledPane.isActive()).toBe(true)

  describe 'open a new pane with config', ->
    it 'should split to the left', ->
      runs ->
        atom.config.set('coffee-compile.split', 'Left')
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'compileOrStack to be called', ->
        util.compileOrStack.callCount > 0

      runs ->
        expect(atom.workspace.paneContainer.root.orientation).toBe 'horizontal'
        expect(atom.workspace.getPanes()).toHaveLength 2
        [compiledPane, editorPane] = atom.workspace.getPanes()

        expect(editorPane.items).toHaveLength 1
        expect(editorPane.items[0]).toBe editor

    it 'should split to the bottom', ->
      runs ->
        atom.config.set('coffee-compile.split', 'Down')
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'compileOrStack to be called', ->
        util.compileOrStack.callCount > 0

      runs ->
        expect(atom.workspace.paneContainer.root.orientation).toBe 'vertical'
        expect(atom.workspace.getPanes()).toHaveLength 2
        [editorPane, compiledPane] = atom.workspace.getPanes()

        expect(editorPane.items).toHaveLength 1
        expect(editorPane.items[0]).toBe editor

    it 'should split to the up', ->
      runs ->
        atom.config.set('coffee-compile.split', 'Up')
        atom.commands.dispatch workspaceElement, 'coffee-compile:compile'

      waitsFor 'compileOrStack to be called', ->
        util.compileOrStack.callCount > 0

      runs ->
        expect(atom.workspace.paneContainer.root.orientation).toBe 'vertical'
        expect(atom.workspace.getPanes()).toHaveLength 2
        [compiledPane, editorPane] = atom.workspace.getPanes()

        expect(editorPane.items).toHaveLength 1
        expect(editorPane.items[0]).toBe editor

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
