_delvalue: (key, type, cb) ->
	stores = @_stores
	switch type
		when 'simple'
			del = stores.simple.delete key
			del.onsuccess = cb
		when 'hash'
			range = IDBKeyRange.bound [key, 0], [key, 1], true, true
			del   = stores.hash.delete range
			del.onsuccess = cb
		else
			do cb
	return
