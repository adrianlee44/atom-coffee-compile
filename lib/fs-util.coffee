fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'

module.exports =
  toExt: (srcPath, ext) ->
    srcExt = path.extname srcPath
    return path.join(
      path.dirname(srcPath),
      "#{path.basename(srcPath, srcExt)}.#{ext}"
    )

  resolvePath: (srcPath) ->
    relative = atom.config.get('coffee-compile.destination') or '.'
    flatten = atom.config.get('coffee-compile.flatten')

    [projectPath, relativePath] = atom.project.relativizePath(srcPath)

    # Remove all path parts
    if flatten
      relativePath = path.basename relativePath

    return path.join projectPath, relative, relativePath

  writeFile: (filename, data, callback) ->
    folder = path.dirname filename

    mkdirp folder, (err) ->
      throw err if err?

      fs.writeFile filename, data, callback
