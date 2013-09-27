_ttlmap: (key, cb, f) ->
	@_checkttl key, (keyinfo) ->
		if keyinfo isnt undefined
			ret = -1
			if keyinfo.expire?
				ret = keyinfo.expire - Date.now()
				ret = f ret if f?
			cb ret
		else
			cb -2
	return
