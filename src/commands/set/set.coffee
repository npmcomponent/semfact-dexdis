set: (key, value, cb) ->
	{keys, values} = @_stores
	keyinfo =
		type: 'simple'
	keys.put keyinfo, key
	put = values.put value, key
	put.addEventListener 'success', ->
		cb 'OK'
	return
