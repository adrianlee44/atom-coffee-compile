var CoffeeCompileEditor, querystring, url, util;

url = require('url');

querystring = require('querystring');

CoffeeCompileEditor = require('./coffee-compile-editor');

util = require('./util');

module.exports = {
  config: {
    grammars: {
      type: 'array',
      "default": ['source.coffee', 'source.litcoffee', 'text.plain', 'text.plain.null-grammar']
    },
    noTopLevelFunctionWrapper: {
      type: 'boolean',
      "default": true
    },
    compileOnSave: {
      type: 'boolean',
      "default": false
    },
    compileOnSaveWithoutPreview: {
      type: 'boolean',
      "default": false
    },
    focusEditorAfterCompile: {
      type: 'boolean',
      "default": false
    }
  },
  activate: function() {
    atom.commands.add('atom-workspace', {
      'coffee-compile:compile': (function(_this) {
        return function() {
          return _this.display();
        };
      })(this)
    });
    if (atom.config.get('coffee-compile.compileOnSaveWithoutPreview')) {
      atom.commands.add('atom-workspace', {
        'core:save': (function(_this) {
          return function() {
            return _this.save();
          };
        })(this)
      });
    }
    return atom.workspace.addOpener(function(uriToOpen) {
      var pathname, protocol, ref, sourceEditor, sourceEditorId;
      ref = url.parse(uriToOpen), protocol = ref.protocol, pathname = ref.pathname;
      if (pathname) {
        pathname = querystring.unescape(pathname);
      }
      if (protocol !== 'coffeecompile:') {
        return;
      }
      sourceEditorId = pathname.substr(1);
      sourceEditor = util.getTextEditorById(sourceEditorId);
      if (sourceEditor == null) {
        return;
      }
      return new CoffeeCompileEditor({
        sourceEditor: sourceEditor
      });
    });
  },
  save: function() {
    var editor;
    editor = atom.workspace.getActiveTextEditor();
    if ((editor == null) || !util.checkGrammar(editor)) {
      return;
    }
    return util.compileToFile(editor);
  },
  display: function() {
    var activePane, editor;
    editor = atom.workspace.getActiveTextEditor();
    activePane = atom.workspace.getActivePane();
    if (editor == null) {
      return;
    }
    if (!util.checkGrammar(editor)) {
      return console.warn("Cannot compile non-Coffeescript to Javascript");
    }
    return atom.workspace.open("coffeecompile://editor/" + editor.id, {
      searchAllPanes: true,
      split: "right"
    }).then(function() {
      if (atom.config.get('coffee-compile.focusEditorAfterCompile')) {
        return activePane.activate();
      }
    });
  }
};
