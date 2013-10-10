flushdb: (cb) ->
	stores = @_stores
	do stores.keys.clear
	for store in storenames
		do stores[store].clear
	cb 'OK'
	return
