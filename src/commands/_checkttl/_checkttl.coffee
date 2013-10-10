_checkttl: (key, cb) ->
	{keys, simple} = @_stores
	get = keys.get key
	get.onsuccess = ->
		keyinfo = get.result
		if keyinfo?.expire?
			if Date.now() > keyinfo.expire
				del = keys.delete key
				del.onsuccess = ->
					cb undefined, true
				simple.delete key
			else
				cb keyinfo, false
		else
			cb keyinfo, false
	return
