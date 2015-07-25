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
    destination = atom.config.get('coffee-compile.destination') or '.'
    flatten     = atom.config.get('coffee-compile.flatten')
    cwd         = atom.config.get('coffee-compile.cwd') or '.'

    [projectPath, relativePath] = atom.project.relativizePath(srcPath)

    # Remove all path parts
    if flatten
      relativePath = path.basename relativePath

    relativePath = path.relative cwd, relativePath
    return path.join projectPath, destination, relativePath

  writeFile: (filename, data, callback) ->
    folder = path.dirname filename

    mkdirp folder, (err) ->
      throw err if err?

      fs.writeFile filename, data, callback

  isPathInSrc: (srcPath) ->
    source = atom.config.get('coffee-compile.source') or ['.']
    cwd    = atom.config.get('coffee-compile.cwd') or '.'

    [projectPath, relativePath] = atom.project.relativizePath(srcPath)

    source.some (folderPath) ->
      fullFolderPath = path.join projectPath, cwd, folderPath
      relative = path.relative srcPath, fullFolderPath

      return relative isnt "" and !/\w+/.test(relative)
