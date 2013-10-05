persist: (key, cb) ->
	keys = @_stores.keys
	@_checkttl key, (keyinfo) ->
		if keyinfo isnt undefined
			ret = 0
			if keyinfo.expire?
				delete keyinfo.expire
				ret = 1
			r = keys.put keyinfo, key
			r.onsuccess = ->
				cb ret
		else
			cb 0
	return
