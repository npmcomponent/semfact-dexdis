_getstr: (key, cb) ->
	error = @onerror
	@get key, (val) ->
		if val?
			type = typeof val
			if type isnt 'string'
				if type is 'number'
					val = '' + val
				else
					error Error errs.wrongtype
					return
		else
			val = ''
		cb val
