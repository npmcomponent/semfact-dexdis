hdel: (key, fields..., cb) ->
	if fields.length is 0
		cb 0
		return
	{hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) ->
		if keyinfo?
			count  = 0
			called = 0
			max    = fields.length
			for field, i in fields
				do (field) ->
					hkey = [key, 0, field]
					cnt  = hash.count hkey
					cnt.onsuccess = ->
						called++
						if cnt.result is 1
							count++
							del = hash.delete hkey
						if called is max
							cb count
		else
			cb 0
