get: (key, cb) ->
	{keys, simple} = @_stores
	@_checkttl key, (keyinfo) ->
		if keyinfo is undefined
			cb null
		else if keyinfo.type isnt 'simple'
			throw new Error errs.wrongtype
		else
			get = simple.get key
			get.onsuccess = ->
				cb get.result
	return
