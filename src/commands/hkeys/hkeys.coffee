hkeys: (key, cb) ->
	ret = []
	@hcursor key, (cursor) ->
		if cursor?
			if cursor.key isnt undefined
				ret.push cursor.key[2]
				cursor.continue()
			else
				cb ret
		else
			cb ret
