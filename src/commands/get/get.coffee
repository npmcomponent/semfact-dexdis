get: (key, cb) ->
	{keys, simple} = @_stores
	@_checkttl key, 'simple', (keyinfo) ->
		if keyinfo is undefined
			cb null
		else
			get = simple.get key
			get.onsuccess = ->
				cb get.result
	return
