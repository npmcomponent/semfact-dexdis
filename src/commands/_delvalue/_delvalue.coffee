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
		when 'list'
			@_checkttl key, 'list', (keyinfo) =>
				if keyinfo is undefined
					cb()
					return
				else
					_lwalk keyinfo,
					       null,
					       (index, elem, key) ->
					       		stores.list.delete key
					       ,
					       true,
					       () ->
					       		del = stores.keys.delete key
					       		del.onsuccess = cb
		else
			do cb if cb?
	return
