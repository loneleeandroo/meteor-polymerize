fs = Npm.require("fs")
path = Npm.require("path")
vulcan = Npm.require("vulcanize")

class Bower
  constructor: (@base_path, @isMain = false) ->
    @bower_json_path = path.join(@base_path, 'bower.json')
    @bower_rc_path = path.join(@base_path, '.bowerrc')
    
    @encoding = 'utf8'
    
    @defaults = {
      json: {
        "name": process.env.PWD.split(path.sep).pop()
        "private": true
        "dependencies": {}
      }
      rc: {
        "directory": "public/bower_components"
      }
    }
    
    @json = JSON.parse(@getFile(@bower_json_path, @encoding, @defaults.json))
    @rc = JSON.parse(@getFile(@bower_rc_path, @encoding, @defaults.rc))
      
  ###
  # Gets file. Will create the file if it doesn't exist.
  #
  # @params filePath {String}
  # @params encoding {String}
  # @params initialContent {String}
  ###  
  getFile: (filePath, encoding = @encoding, initialContent) ->
    file = false
    
    try
      file = fs.readFileSync(filePath, encoding)
    catch e  
      if e.code is 'ENOENT' and e.errno is 34 and @isMain
        @writeFile(filePath, JSON.stringify(initialContent, null, 2), encoding)
        file = fs.readFileSync(filePath, encoding)
      else
        file = false  
        
    return file  
    
  ###
  # Writes file.
  #
  # @params filePath {String}
  # @params contents {String}
  # @params encoding {String}
  ###    
  writeFile: (filePath, contents, encoding = @encoding) ->
    return fs.writeFileSync(filePath, contents, encoding)
    
  ###
  # Checks whether bower has dependencies
  #
  # @params dependencies {Array}
  ###
  hasDependencies: (dependencies = []) ->
    intersection = _.intersection(dependencies, _.keys(@json.dependencies))
    return intersection.length is dependencies.length
    
  ###
  # Adds dependencies to bower
  #
  # @params dependencies {Array}
  ###  
  addDependencies: (dependencies = []) ->
    updatedJson = @json
    
    updatedJson.dependencies = {} unless updatedJson.dependencies
    updatedJson.overrides = {} unless updatedJson.overrides
    
    _.each dependencies, (dependency) ->
      updatedJson.dependencies[dependency.name] = dependency.version
      
      if dependency.main
        updatedJson.overrides[dependency.name] = {
          main: dependency.main
        }
      
    @writeFile(@bower_json_path, JSON.stringify(updatedJson, null, 2))

  ###
  # Replace dependency with other dependencies from bower
  #
  # @params replaceDependency {String}
  # @params dependencies {Array}
  ###  
  replaceDependency: (replaceDependency, dependencies = []) -> 
    updatedJson = @json

    newDependencies = {}

    updatedJson.dependencies = {} unless updatedJson.dependencies
    updatedJson.overrides = {} unless updatedJson.overrides

    _.each updatedJson.dependencies, (version, name) ->
      if name is replaceDependency
        _.each dependencies, (dependency) ->
          newDependencies[dependency.name] = dependency.version
          
          if dependency.main
            updatedJson.overrides[dependency.name] = {
              main: dependency.main
            }
      else
        newDependencies[name] = version

    updatedJson.dependencies = newDependencies  
      
    @writeFile(@bower_json_path, JSON.stringify(updatedJson, null, 2))
    
  ###
  # Gets HTML imports. Looks at the main file in a dependencies
  # bower.json. If there is an override, that file will be used instead.
  # The load order will be determined by the order of the dependency.
  ###  
  getHTMLImports: ->
    directory = path.join(@base_path, @rc.directory)
    hasDirectory = true

    dependencies = @json.dependencies
    overrides = @json.overrides
    imports = []
    
    _.each dependencies, (version, name) =>
      dependency_bower = new Bower(path.join(directory, name))
    
      if overrides and overrides[name]
        mainFiles = overrides[name].main
      else  
        mainFiles = dependency_bower.json.main

      # if the main entry is empty
      mainFiles = name + '.html' unless mainFiles

      # If the main entry is not an array.
      mainFiles = [mainFiles] unless _.isArray(mainFiles)
          
      # If the main entry has no extension, add .html extension
      mainFiles = _.map mainFiles, (mainFile) ->
        mainFile += '.html' unless path.extname(mainFile)
        return mainFile 

      # Check if all main files exists
      mainFiles = _.filter mainFiles, (mainFile) ->
        if dependency_bower.getFile(path.join(directory, name, mainFile))
          return true
        else
          return false

      try
        fs.readdirSync(directory) 
      catch e 
        if e.code is 'ENOENT' and e.errno is 34 
          hasDirectory = false
    
      # No main entry can be derived, add all its dependencies to the bower.json instead.
      if hasDirectory and _.isEmpty(mainFiles)
        newDependencies = []
        _.each dependency_bower.json.dependencies, (dependencyVersion, dependencyName) ->
          newDependencies.push {
            name: dependencyName
            version: dependencyVersion
          }

        @replaceDependency(name, newDependencies)  
      
      # Import HTML files only.
      _.each mainFiles, (file) ->
        if path.extname(file) is '.html'
          imports.push({
            directory: name
            file: file
          })    

    return imports
      
class Polymerizer
  constructor: ->
    @base_path = path.relative(process.cwd(), process.env.PWD)
    @bower = new Bower(@base_path, true)
    @ENV = process.env

    @assets = [
      # { name: "patch-dom" }
    ]

    @dependencies = [
      {
        name: "webcomponentsjs"
        version: "^0.7.2"
      }
      {
        name: "polymer"
        version: "Polymer/polymer#^1.0.0"
      }
    ]

    
  ###
  # Initialisation Process
  ###      
  init: ->
    
    # Vulcanize if the node environment is 'production' or 
    # the environment variable VULCANIZE is set to TRUE
    if @ENV.NODE_ENV is 'production' or @ENV.VULCANIZE
      htmlImports = @vulcanize()
    else
      htmlImports = @getHTMLimports()

    # Insert the import links to the end of the <head> of the document.
    Meteor.startup ->
      Inject.rawModHtml 'polymer', (html) ->
        html = html.replace '</head>', htmlImports + '</head>'
        
      Inject.rawModHtml 'addUnresolved', (html) ->
        html = html.replace '<body>', '<body unresolved class="fullbleed layout vertical">' 
        
  ###
  # Vulcanize all HTML import files.
  #
  # @params name {String}
  # @params options {Object}
  ###
  vulcanize: (name = 'vulcanized', options) ->
    target = path.join(@base_path, 'public', name + '.html')
    htmlImports = @getHTMLimports()
    
    fs.writeFileSync(target, htmlImports, 'utf8')
    
    unless options
      options = {
        absPath: ''
        excludes: []
        stripExcludes: false
        inlineScripts: true
        inlineCss: true
        implicitStrip: false
        stripComments: false
      }
    
    vulcan.setOptions options
      
    vulcan.process target, (error, inlineHTML) ->
      fs.writeFileSync(target, inlineHTML, 'utf8')
    
    return '<link rel="import" href="/' + name + '.html">'
    
  ###
  # Get list of HTML import files.
  ###  
  getHTMLimports: ->
    dependencies = _.map @dependencies, (dependency) ->
      return dependency.name
      
    unless @bower.hasDependencies(dependencies)   
      @bower.addDependencies(@dependencies)
      
    htmlImports = @bower.getHTMLImports()  
    links = ''
    
    _.each htmlImports, (htmlImport) ->
      links += '<link rel="import" href="/bower_components/' + htmlImport.directory + '/' + htmlImport.file + '">'

    _.each @assets, (asset) ->
      links += '<link rel="import" href="/packages/loneleeandroo_polymerize/' + asset.name + '.html">'  
    
    return links
        
###
# Starts Polymerizer
###      
Polymerizer = new Polymerizer()
Polymerizer.init()