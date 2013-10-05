get: (key, cb) ->
	{keys, values} = @_stores
	@_checkttl key, (keyinfo) ->
		if keyinfo is undefined
			cb null
		else if keyinfo.type isnt 'simple'
			throw new Error errs.wrongtype
		else
			get = values.get key
			get.onsuccess = ->
				cb get.result
	return
