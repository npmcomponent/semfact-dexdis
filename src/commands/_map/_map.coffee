_map: (key, cb, f) ->
	{keys, simple} = @_stores
	value = null
	@_checkttl key, 'simple', (keyinfo) =>
		if keyinfo?
			get = simple.get key
			get.onsuccess = ->
				value = f get.result
				put = simple.put value, key
				put.onsuccess = ->
					cb value
		else
			value = f null
			@set key, value, ->
				cb value
	return
