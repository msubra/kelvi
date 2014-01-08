
class Cache

	@timeout = 1000 * 60 #60 seconds	
	@cache = {}
	@_size = 0

	@reset : () ->
		@cache = null
		@cache = {}
		@_size = 0

	@hash : (o) -> o

	@has : (key) -> @hash(key) of @cache # typeof(@cache[@hash(key)]) != 'undefined' and @cache[@hash(key)] != null

	class CacheEntry
		#default timeout is 60s
		constructor: (@key,@value,timeout=@timeout) -> 
			@expiryTime = new Date().getTime() + timeout

		hasExpired : () -> new Date().getTime() > @expiryTime

	@get : (key) ->
		entry = @cache[@hash(key)]
		if entry then entry.value

	@put : (key,value,timeout=@timeout) ->
		entry = new CacheEntry(key,value,timeout)
		@cache[@hash(entry.key)] = entry
		@_size++

		hook = () => 
			@expire(key) 
			@_size--

		entry.expiryHandle = window.setTimeout  hook , timeout

		return entry

	@remove : (key) -> @expire key

	@expire : (key) ->

		entry = @get(key)

		if entry
			#invalidate the expiry timer
			clearTimeout(entry.expiryHandle)
			entry.expiryHandle = null
			delete entry.expiryHandle

			#remove the object from cache
			delete @cache[@hash(key)]

			# reduce the size
			@_size--

	@items: () ->
		out = {}
		for key,value of @cache
			out[key] = value

		return out

	@size: () ->
		@_size
