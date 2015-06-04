fs = Npm.require("fs")
path = Npm.require("path")

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
  # Gets HTML imports. Looks at the main file in a dependencies
  # bower.json. If there is an override, that file will be used instead.
  # The load order will be determined by the order of the dependency.
  ###  
  getHTMLImports: ->
    directory = path.join(@base_path, @rc.directory)
    dependencies = @json.dependencies
    overrides = @json.overrides
    imports = []
    
    _.each dependencies, (version, name) ->
      dependency_bower = new Bower(path.join(directory, name))
    
      if overrides[name]
        mainFiles = overrides[name].main
      else  
        mainFiles = dependency_bower.json.main

        # if the main entry is empty
        unless mainFiles
          fileName = name + '.html'
          if dependency_bower.getFile(path.join(directory, name, fileName))
            mainFiles = fileName 

        # If the main entry is not an array.
        unless _.isArray(mainFiles)
          mainFiles = [mainFiles]
      
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
    @dependencies = [
      {
        name: "webcomponentsjs"
        version: "^0.7.2"
        main: [
          "webcomponents-lite.js"
        ]
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
    @importHTML()
    
  ###
  # Imports all html files in bower
  ###    
  importHTML: ->
    dependencies = _.map @dependencies, (dependency) ->
      return dependency.name
      
    unless @bower.hasDependencies(dependencies)   
      @bower.addDependencies(@dependencies)
      
    htmlImports = @bower.getHTMLImports()  
    links = ''
    
    _.each htmlImports, (htmlImport) ->
      links += '<link rel="import" href="bower_components/' + htmlImport.directory + '/' + htmlImport.file + '">'
    
    Meteor.startup ->
      Inject.rawModHtml 'polymer', (html) ->
        html = html.replace '</head>', links + '</head>'
        
###
# Starts Polymerizer
###      
Polymerizer = new Polymerizer()
Polymerizer.init()