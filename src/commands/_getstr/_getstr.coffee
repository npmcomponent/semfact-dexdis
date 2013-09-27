_getstr: (key, cb) ->
	@get key, (val) ->
		if val?
			type = typeof val
			if type isnt 'string'
				if type is 'number'
					val = '' + val
				else
					throw new Error errs.wrongtype
		else
			val = ''
		cb val
