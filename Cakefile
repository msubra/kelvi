fs = require 'fs'
sys = require 'sys'

rimraf = require 'rimraf'
ncp = require('ncp').ncp
{exec} = require 'child_process'
zip = new require('node-zip')();

#define settings
ncp.limit = 16;
alreadyRan = no

# define directories
target_dir = 'build'
target_app_dir = "#{target_dir}/app"
target_chrome_app_dir = "#{target_dir}/chrome-app"
KELVI_VERSION="1.0"

###

/build - contains all the built artifacts
/build/kelvi-<version>.zip  - contains the zip builds for various versions
/build/kelvi-latest.zip  - the latest build
/build/kelvi-latest-chrome-app.zip  - the latest chrome-app build

###

build_dir = "build"
CURRENT_VERSION = "1.0"

#recursively delete a folder
rmr = (path) -> rimraf.sync path

#create a folder if it doesnt exists
createFolderIfNotExists = (folder,callback=()->) ->
    fs.exists folder,(exists) ->
        if not exists
            fs.mkdirSync folder, (err,stdout,stderr) ->
                if err
                    console.log err
                callback()


task 'clean:all', 'clean all the relevent folders', ->
    rimraf.sync target_dir 

task 'build:all', 'create all required build packages', ->
    invoke 'clean:all'
    invoke 'create:app'
    invoke 'create:chrome-app'

task 'create:app', 'create all target folders', ->
    console.log "Creating app"
    invoke 'create:target-app-folders'
    invoke 'create:copy-dependencies'
    invoke 'compile:all'
    invoke 'create:package-app'
    
    
task 'create:package-app', 'create all packages', ->
    console.log "creating packages"

    setTimeout () ->
        child = exec "zip -r #{target_dir}/kelvi-#{KELVI_VERSION}.zip #{target_app_dir}", (error, stdout, stderr) ->
            console.log('exec:' + stdout);
            rimraf.sync target_app_dir
    ,1000

task 'watch:app', 'create all target folders', ->
    invoke 'create:app'
    fs.watch 'src', () ->
        invoke 'create:app'

task 'create:target-app-folders', 'create all target folders', ->
    folders = [target_dir,target_app_dir]
    for folder in folders
        createFolderIfNotExists folder

task 'create:copy-dependencies', 'copy all required dependencies', ->
    console.log "copying dependencies"
    folders = [
        'css/',
        'js/',
        'images/'
    ]

    for file in folders
        createFolderIfNotExists "#{target_app_dir}/#{file}"

    dependencies = [
        'kelvi.html',
        'config.html',
        'css/style.css'
        'gear.png',
        'js/jquery.min-1.10.2.js',
        'js/angular.min-1.2.6.js',
        'js/jaadi-1.0.js',
        'images/',
    ]

    for file in dependencies
        if fs.existsSync #{target_app_dir}
            target_file = "#{target_app_dir}/#{file}"
            console.log "reading from #{file} and writing to #{target_file}"            
            ncp file ,target_file

task 'compile:all', 'compile all coffeescript modules', ->
    console.log "compiling modules"

    files = [
        "config",
        "sodashboard",
        "app",
    ]

    single_src = "#{target_app_dir}/kelvi-#{KELVI_VERSION}.coffee"

    contents = new Array 
    remaining = files.length

    for file, index in files then do (file, index) ->
        fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
          throw err if err
          contents[index] = fileContents

          #chaining process fn here
          process() if --remaining is 0

    process = ->
        fs.writeFile single_src, contents.join('\n\n'), 'utf8', (err) ->
          throw err if err
    
    exec "coffee --compile --bare --output  #{target_app_dir}/js #{single_src}", (err, stdout, stderr) ->
        if err
            throw err
        else
            rimraf.sync single_src



task 'create:package', 'creating required package bundles', ->
    console.log "create package"

task 'create:chrome-app', 'creating chrome-app', ->
    console.log "create chrome app"

    foldersToCopy = ["chrome-app",target_app_dir]
    copySeq = (target,first,rest...) ->
        console.log "copying #{first}/ to #{target}"
        ncp "#{first}/", target
        if rest.length > 0
            setTimeout () ->
                copySeq target, rest
            ,500

    copySeq target_chrome_app_dir,foldersToCopy...

    #create chrome-zip package
    setTimeout () ->
        child = exec "zip -r #{target_dir}/kelvi-chrome-app-#{KELVI_VERSION}.zip #{target_chrome_app_dir}", (error, stdout, stderr) ->
            console.log('exec:' + stdout);

            #delete chrome-app dir after zip is created
            rimraf.sync target_chrome_app_dir
    ,1000


