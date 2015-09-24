path          = require 'path'
configManager = require './config-manager'
{File} = require 'atom'

module.exports =
  toExt: (srcPath, ext) ->
    srcExt = path.extname srcPath
    return path.join(
      path.dirname(srcPath),
      "#{path.basename(srcPath, srcExt)}.#{ext}"
    )

  resolvePath: (srcPath) ->
    destination = configManager.get('destination') or '.'
    flatten     = configManager.get('flatten')
    cwd         = configManager.get('cwd') or '.'

    [projectPath, relativePath] = atom.project.relativizePath(srcPath)

    # Remove all path parts
    if flatten
      relativePath = path.basename relativePath

    relativePath = path.relative cwd, relativePath
    return path.join projectPath, destination, relativePath

  writeFile: (filename, data) ->
    file = new File(filename)
    file.create().then ->
      file.write data

  isPathInSrc: (srcPath) ->
    source = configManager.get('source') or ['.']
    cwd    = configManager.get('cwd') or '.'

    [projectPath, relativePath] = atom.project.relativizePath(srcPath)

    return false unless projectPath

    # Convert source to an array when the type is string
    if typeof source is 'string'
      source = [source]
    # Default to `['.']` when source is other type
    else if not Array.isArray(source)
      source = ['.']

    source.some (folderPath) ->
      # if for some reason projectPath, cwd or folderPath aren't strings
      if typeof projectPath isnt 'string' or
          typeof cwd isnt 'string' or
          typeof folderPath isnt 'string'
        return false

      fullFolderPath = path.join projectPath, cwd, folderPath
      relative = path.relative srcPath, fullFolderPath

      return relative isnt "" and !/\w+/.test(relative)
