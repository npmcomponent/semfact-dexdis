flushall: (cb) ->
	{keys, values} = @_stores
	do keys.clear
	do values.clear
	cb 'OK'
	return
