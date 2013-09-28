dbsize: (cb) ->
	keys = @_stores.keys
	cnt = keys.count()
	cnt.addEventListener 'success', ->
		cb cnt.result
