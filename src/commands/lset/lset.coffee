lset: (key, index, value, cb) ->
	{list} = @_stores
	@_checkttl key, 'list', (keyinfo) =>
		if keyinfo is undefined
			@onerror new Error errs.wrongargs
			return
		else
			@_lwalk keyinfo,
			       (i, elem) ->
			       		i is index
			       ,
			       null,
			       index >= 0,
			       (i, elem, key) =>
			       		if i is null
			       			@onerror new Error errs.wrongargs
			       			return
			       		else
			       			elem.value = value
			       			put = list.put elem, key
			       			put.onsuccess = ->
			       				cb 'OK'
			       				return
			       		return
	return
