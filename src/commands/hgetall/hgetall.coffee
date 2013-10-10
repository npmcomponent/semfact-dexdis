hgetall: (key, cb) ->
	ret = []
	@hcursor key, (cursor) ->
		if cursor?
			if cursor.key isnt undefined
				ret.push cursor.key[2]
				ret.push cursor.value
				cursor.continue()
			else
				cb ret
		else
			cb ret
