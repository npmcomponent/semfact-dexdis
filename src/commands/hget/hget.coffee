hget: (key, field, cb) ->
	{hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) ->
		if keyinfo?
			get = hash.get [key, 0, field]
			get.onsuccess = ->
				if get.result is undefined
					cb null
				else
					cb get.result
		else
			cb null
