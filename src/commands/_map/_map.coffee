_map: (key, cb, f) ->
	{keys, values} = @_stores
	value = null
	@_checkttl key, (keyinfo) =>
		if keyinfo?
			if keyinfo.type is 'simple'
				get = values.get key
				get.addEventListener 'success', ->
					value = f get.result
					put = values.put value, key
					put.addEventListener 'success', ->
						cb value
			else
				cb new Error errs.wrongtype
		else
			value = f null
			@set key, value, ->
				cb value
	return
