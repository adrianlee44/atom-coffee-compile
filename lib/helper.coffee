path = require "path"

module.exports =
  extend: (obj, args...) ->
    for source in args
      for own prop of source
        obj[prop] = source[prop]

    return obj

  compileOptions: (editor, options) ->
    grammarScopeName = editor.getGrammar().scopeName

    sourceFile = editor.getPath()
    filepath   = path.dirname sourceFile

    sourceExt = path.extname sourceFile
    destPath  = path.join filepath, atom.config.get "coffee-compile.compileDirectory"
    destFile  = "#{path.basename(sourceFile, sourceExt)}.js"

    # Compute source map directory
    sourceMapDirectory = atom.config.get "coffee-compile.sourceMapDirectory"
    sourceMapAbs       = path.join filepath, sourceMapDirectory

    opts =
      filename:      sourceFile
      literate:      grammarScopeName is "source.litcoffee"
      bare:          atom.config.get "coffee-compile.noTopLevelFunctionWrapper"
      sourceMap:     atom.config.get "coffee-compile.sourceMap"
      sourceRoot:    path.relative destPath, filepath
      sourceMapDir:  sourceMapAbs
      sourceMapPath: path.join sourceMapAbs, "#{destFile}.map"
      sourceFiles:   [path.basename(sourceFile)]
      generatedDir:  destPath
      generatedFile: destFile
      generatedPath: path.join destPath, destFile

    return @extend opts, options
