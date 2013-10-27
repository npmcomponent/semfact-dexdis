lindex: (key, index, cb) ->
	@_lwalk key,
	       (i, elem) ->
	       		i is index
	       ,
	       null,
	       (index, elem, key) ->
	       		if index is null
	       			cb null
	       		else
	       			cb elem.value
	return
