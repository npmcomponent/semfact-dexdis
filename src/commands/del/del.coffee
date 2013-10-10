del: (dels..., cb) ->
	{keys, simple} = @_stores
	if dels.length is 0
		cb 0
		return
	count = 0
	for k, i in dels
		@_checkttl k, (keyinfo) ->
			if keyinfo?
				count++
				keys.delete k
				del = simple.delete k
				if i is dels.length
					del.onsuccess = ->
						cb count
