'use strict';

const {TextEditor} = require('atom');
const configManager = require('./config-manager');
const util = require('./util');
const fsUtil = require('./fs-util');
const pluginManager = require('./plugin-manager');

class PreviewEditor extends TextEditor {
  constructor(sourceEditor) {
    super({autoHeight: false});

    this._sourceEditor = sourceEditor;

    let shouldCompileToFile = !!this._sourceEditor &&
        fsUtil.isPathInSrc(this._sourceEditor.getPath()) &&
        pluginManager.isSelectionLanguageSupported(this._sourceEditor, true);

    this.disposables.add(this._sourceEditor.onDidSave(() => {
      let shouldWriteToFile = shouldCompileToFile &&
          configManager.get('compileOnSave') &&
          !configManager.get('compileOnSaveWithoutPreview');
      return util.renderAndSave(previewEditor, this._sourceEditor, shouldWriteToFile);
    }));

    if (shouldCompileToFile && (configManager.get('compileOnSave') || configManager.get('compileOnSaveWithoutPreview'))) {
      util.compileToFile(this._sourceEditor);
    }

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
