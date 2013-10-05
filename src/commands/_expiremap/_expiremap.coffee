_expiremap: (key, cb, f) ->
	keys = @_stores.keys
	@_checkttl key, (keyinfo) ->
		if keyinfo isnt undefined
			keyinfo.expire = f keyinfo.expire
			r = keys.put keyinfo, key
			r.onsuccess = ->
				cb 1
		else
			cb 0
	return
