fs = require 'fs'

ncp = require('ncp').ncp
ncp.limit = 16;
alreadyRan = no
{exec} = require 'child_process'

# define directories
target_dir = 'target'
target_app_dir = "#{target_dir}/app"
target_chrome_app_dir = "#{target_dir}/chrome-app"


task 'say:hello', 'Desc', ->
	console.log 'Hello'

task 'create:target', 'create target folder', ->
    #create target folder
    fs.mkdir "#{target_dir}"
    fs.mkdir "#{target_app_dir}"


task 'copy:dependencies', 'copy dependencies', ->

    #create target folders
    invoke 'create:target'

    folders = [
        'css/'
        'js/'
    ]

    for file in folders
        fs.mkdir "#{target_app_dir}/#{file}"

    dependencies = [
        'kelvi.html',
        'config.html',
        'css/style.css'
        'gear.png',
        'js/jquery.min-1.10.2.js',
        'js/angular.min-1.2.6.js'
    ]

    for file in dependencies
        console.log "reading from #{file} and writing to #{target_app_dir}/#{file}"
        fs.createReadStream(file).pipe(fs.createWriteStream("#{target_app_dir}/#{file}"));

task 'create:dist', 'create distro', ->
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


task 'create:chrome-app', 'create chrome app distro', ->

    #create the basic distro
    invoke 'create:dist'

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

