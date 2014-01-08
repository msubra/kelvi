class JaadiPlugin
    constructor : () ->
    get: (key) ->
    put: (key,value) ->
    remove: (key) ->
    size:  () ->


###
Storage plugin for Chrome Local Storage object
###
class ChromeLocalStoragePlugin extends JaadiPlugin
    constructor : () ->
    get: (key) ->   JSON.parse chrome.storage.local.get(key)
    put: (key,value) ->   chrome.storage.local.put(key,JSON.stringify value)
    remove: (key) ->   chrome.storage.local.remove(key)
    size: () -> chrome.storage.local.length

###
Storage plugin for W3C DOM Local Storage object
###

class W3CLocalStoragePlugin extends JaadiPlugin
    constructor : () ->
    get: (key) ->   JSON.parse window.localStorage.getItem(key)
    put: (key,value) ->   window.localStorage.setItem(key,JSON.stringify value)
    remove: (key) ->   window.localStorage.removeItem(key)
    size: () -> window.localStore.length

class Container
    
    ###
        default javascript DOM storage implementation
    ###
    class DomStoragePlugin extends JaadiPlugin
        constructor : () ->
            @_container = {}
        get: (key) -> @_container[key]
        put: (key,value) -> @_container[key] = value
        remove: (key) -> delete @_container[key]
        size: () -> 
            length = 0
            console.log @_container
            for key,val of @_container
                length++
            return length

    @createInstance = (name) =>
        try
            jaadiType = @plugins.get(name)

            # if there is no name attribute, then it is not a class. It may be a function which decides the class on the fly #
            if not jaadiType.name?
                jaadiType = jaadiType.call()
                jaadiType = new jaadiType
            else
                jaadiType = new jaadiType
        catch
            jaadiType = new DomStoragePlugin()

        return jaadiType

    @plugins = new DomStoragePlugin()
    @plugins.add = (key,value) -> this.put(key,value)

    # add some default plugins
    
    # Javascript DOM storage
    @plugins.add("dom",DomStoragePlugin)

    # Browser Local Storage
    @plugins.add("localstorage",()->
        # always return singleton instance
        window["_locs"] = [new W3CLocalStoragePlugin(),new ChromeLocalStoragePlugin()]

        try
            # check if W3C localStorage is available
            window.localStorage         #chrome should throw error for this
            return window["_locs"][0]
        catch
            if(chrome and chrome.storage?)
                return window["_locs"][1]
    )


