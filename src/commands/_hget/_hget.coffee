_hget: (key, field, cb) ->
	{hash} = @_stores
	get = hash.get [key, 0, field]
	get.onsuccess = ->
		if get.result is undefined
			cb null
		else
			cb get.result
