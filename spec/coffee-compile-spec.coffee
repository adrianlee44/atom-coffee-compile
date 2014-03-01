CoffeeCompile = require '../lib/coffee-compile'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "CoffeeCompile", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('coffeeCompile')

  describe "when the coffee-compile:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.coffee-compile')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'coffee-compile:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.coffee-compile')).toExist()
        atom.workspaceView.trigger 'coffee-compile:toggle'
        expect(atom.workspaceView.find('.coffee-compile')).not.toExist()
