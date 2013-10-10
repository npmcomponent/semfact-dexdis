_checkttl: (key, type, cb) ->
	{keys} = @_stores
	error  = @onerror
	if typeof type is 'function'
		cb   = type
		type = null
	checktype = (keyinfo) ->
		if type? and keyinfo? and keyinfo.type isnt type
			error new Error errs.wrongtype
			return
		cb keyinfo
	get = keys.get key
	get.onsuccess = ->
		keyinfo = get.result
		if keyinfo?.expire?
			if Date.now() > keyinfo.expire
				del = keys.delete key
				del.onsuccess = ->
					cb undefined
				@_delvalue k, keyinfo.type, ->
			else
				checktype keyinfo
		else
			checktype keyinfo
	return
