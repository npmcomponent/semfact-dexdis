del: (dels..., cb) ->
	stores = @_stores
	if dels.length is 0
		cb 0
		return
	count   = 0
	called  = 0
	max     = dels.length
	for k in dels
		do (k) =>
			@_checkttl k, (keyinfo) =>
				called++
				if keyinfo?
					count++
					stores.keys.delete k
					@_delvalue k, keyinfo.type
				if called is max
					cb count
	return
