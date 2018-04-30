'use strict';

const {TextEditor} = require('atom');
const configManager = require('./config-manager');
const pluginManager = require('./plugin-manager');

class PreviewEditor extends TextEditor {
  constructor(sourceEditor) {
    super({autoHeight: false});

    this._sourceEditor = sourceEditor;

    // HACK: Override TextBuffer save function since there is no buffer content
    // TODO: Subscribe to saveAs event and convert the editor to use that file
    this.getBuffer().save = function() {};
  }

  getTitle() {
    let title = this._sourceEditor ? this._sourceEditor.getTitle() : ''
    return `Compiled ${title}`.trim();
  }

  getURI() {
    return `coffeecompile://editor/${this._sourceEditor.id}`;
  }

  setText(text) {
    let grammar = atom.grammars.selectGrammar(pluginManager.getCompiledScopeByEditor(this._sourceEditor));
    this.setGrammar(grammar);
    return super.setText(text);
  }

  shouldPromptToSave() {
    return false;
  }
};

module.exports = PreviewEditor;
