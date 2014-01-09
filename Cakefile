fs = require 'fs'

ncp = require('ncp').ncp
ncp.limit = 16;
alreadyRan = no
{exec} = require 'child_process'

# define directories
target_dir = 'target'
target_app_dir = "#{target_dir}/app"
target_chrome_app_dir = "#{target_dir}/chrome-app"


###

/build - contains all the built artifacts
/build/kelvi-<version>.zip  - contains the zip builds for various versions
/build/kelvi-latest.zip  - the latest build
/build/kelvi-latest-chrome-app.zip  - the latest chrome-app build

###

build_dir = "build"
CURRENT_VERSION = "1.0"

task 'create:builds', 'create builds',  ->
    #hold all artifacts to be built in temporary folder /target/
    invoke 'copy:dependencies'

    #compile app
    invoke 'compile:app'

    #compile compile chrome app
    invoke 'compile:chrome-app'

    #create zip packages
    invoke 'create:kelvi-zip'
    invoke 'create:kelvi-chrome-app-zip'

    #copy built artifacts to /build folder
    fs.mkdir "#{build_dir}"
    ncp "#{target_app_dir}/*.zip", build_dir


#recursively delete a folder
rmr = (path) ->
    if fs.existsSync path
        fs.readdirSync(path).forEach((file,index)->
            curPath = path + "/" + file

            if fs.statSync(curPath).isDirectory()
                rmr curPath
                fs.rmdirSync curPath
            else
                fs.unlinkSync curPath
        )

cleanCreateFolder = (folder) ->
    fs.exists folder,(exists) ->
        if exists
            console.log "#{folder} exists. removing"
            rmr folder
        console.log "creating folder #{folder}" 
        fs.mkdir folder, (args) ->

createFolderIfNotExists = (folder) ->
    fs.exists folder,(exists) ->
        if not exists
            console.log "creating folder #{folder}" 
            fs.mkdir folder, (args) ->

task 'create:target', 'create target folder', ->
    folders = [target_dir,target_app_dir]
    for folder in folders
        cleanCreateFolder folder

task 'copy:dependencies', 'copy dependencies', ->

    #create target folders
    invoke 'create:target'

    folders = [
        'css/',
        'js/'
    ]

    for file in folders
        createFolderIfNotExists "#{target_app_dir}/#{file}"

    dependencies = [
        'kelvi.html',
        'config.html',
        'css/style.css'
        'gear.png',
        'js/jquery.min-1.10.2.js',
        'js/angular.min-1.2.6.js'
    ]

    for file in dependencies
        if fs.existsSync #{target_app_dir}
            console.log "reading from #{file} and writing to #{target_app_dir}/#{file}"
            #fs.createReadStream(file).pipe(fs.createWriteStream("#{target_app_dir}/#{file}"))

task 'compile:app', 'create distro', ->
    console.log 'Creating dir ./dist'

    invoke 'create:target'
    invoke 'copy:dependencies'

    concat_result = ''
    target_js = "#{target_app_dir}/js"
    target_coffee_file = "#{target_app_dir}/app.coffee"

    file_order = [
        "dabba.coffee",
        "config.coffee",
        "dashboard.coffee",
        "sodashboard.coffee",
        "app.coffee"
    ]

    console.log file_order

    for file in file_order
        exec "coffee -cb -o #{target_js} src/#{file} ", (err, stdout, stderr) ->
            if err
                console.log 'FAILED:', err
            else
                console.log 'SUCCESS!'


task 'compile:chrome-app', 'create chrome app distro', ->

    #create the basic distro
    invoke 'compile:app'

    # create a seperate app directory  as /target/chrome-app
    
    chrome_target_dir = target_chrome_app_dir
    chrome_src = 'chrome-app'

    if fs.exists(chrome_target_dir)
        fs.rmdir chrome_target_dir
    
    fs.mkdir chrome_target_dir

    #copy the files from chrome-app files into /target/chrome-app
    ncp chrome_src,target_chrome_app_dir

    #copy the files from /target/app into /target/chrome-app
    ncp target_app_dir,target_chrome_app_dir

