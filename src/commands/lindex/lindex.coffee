lindex: (key, index, cb) ->
	@_lwalk key,
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
