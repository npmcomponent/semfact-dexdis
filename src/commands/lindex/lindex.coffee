lindex: (key, index, cb) ->
	@_checkttl key, 'list', (keyinfo) =>
		if keyinfo is undefined
			cb null
			return
		else
			@_lwalk keyinfo,
			       (i, elem) ->
			       		i is index
			       ,
			       null,
			       index >= 0,
			       (i, elem, k) ->
			       		if i is null
			       			cb null
			       			return
			       		else
			       			cb elem.value
			       			return
	return
