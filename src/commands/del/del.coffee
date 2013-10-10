del: (dels..., cb) ->
	stores = @_stores
	if dels.length is 0
		cb 0
		return
	count   = 0
	ignored = 0
	max     = dels.length - 1
	for k, i in dels
		do (k, i) =>
			@_checkttl k, (keyinfo) =>
				if keyinfo?
					count++
					stores.keys.delete k
					@_delvalue k, keyinfo.type, ->
						if i is max
							cb count
				else
					ignored++
					# all keys are nonexistent
					if i is max and ignored > max
						cb 0
	return
