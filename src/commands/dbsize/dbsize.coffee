dbsize: (cb) ->
	keys = @_stores.keys
	cnt = keys.count()
	cnt.onsuccess = ->
		cb cnt.result
