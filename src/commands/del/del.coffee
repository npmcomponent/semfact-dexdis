del: (dels..., cb) ->
	{keys, values} = @_stores
	if dels.length is 0
		cb 0
		return
	count = 0
	for k, i in dels
		@_checkttl k, (keyinfo) ->
			if keyinfo?
				count++
				keys.delete k
				del = values.delete k
				if i is dels.length
					del.addEventListener 'success', ->
						cb count
