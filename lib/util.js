'use strict';

const configManager = require('./config-manager');
const pluginManager = require('./plugin-manager');

module.exports = {

  /**
   * @param {String} id
   * @returns {Editor|null}
   */
  getTextEditorById: function(id) {
    let len;
    let editors = atom.workspace.getTextEditors();
    for (let i = 0, len = editors.length; i < len; i++) {
      let editor = editors[i];
      if (editor.id == id) return editor;
    }
    return null;
  },

  /**
   * @param {Editor} editor
   * @returns {String} Compiled code
   */
  compile: function(editor) {
    const language = pluginManager.getLanguageByScope(editor);
    let code = this.getSelectedCode(editor);

    if (!language) return code;

    let preCompilers = language.preCompilers;
    code = preCompilers.reduce((partialCode, preCompiler) => {
      return preCompiler(partialCode, editor);
    }, code);

    let compilers = language.compilers;
    code = compilers.reduce((partialCode, compiler) => {
      return compiler(partialCode, editor);
    }, code);

    let postCompilers = language.postCompilers;
    return postCompilers.reduce((partialCode, postCompiler) => {
      return postCompiler(partialCode, editor);
    }, code);
  },

  /**
   * @param {Editor} editor
   * @returns {String} Selected text
   */
  getSelectedCode: function(editor) {
    let range = editor.getSelectedBufferRange();
    return range.isEmpty() ? editor.getText() : editor.getTextInBufferRange(range);
  },

  compileOrStack: function(editor) {
    let text;
    try {
      text = this.compile(editor);
    } catch (error) {
      text = error.stack;
    }
    return text;
  },
};
