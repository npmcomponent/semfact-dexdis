hset: (key, field, value, cb) ->
	{keys, hash} = @_stores
	@_checkttl key, (keyinfo) ->
		if keyinfo? and keyinfo.type isnt 'hash'
			throw new Error errs.wrongtype
		hkey = [key, 1, field]
		cnt = hash.count hkey
		cnt.onsuccess = ->
			put = hash.put value, [key, 1, field]
			put.onsuccess = ->
				if cnt.result is 0
					cb 1
				else
					cb 0
