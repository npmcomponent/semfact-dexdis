set: (key, value, cb) ->
	{keys, simple} = @_stores
	keyinfo =
		type: 'simple'
	keys.put keyinfo, key
	put = simple.put value, key
	put.onsuccess = ->
		cb 'OK'
	return
