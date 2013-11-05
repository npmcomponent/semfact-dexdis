linsert: (key, index, value, cb) ->
	{keys, list} = @_stores
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
			       (i, elem, k) =>
			       		if i is null
			       			cb null
			       			return
			       		else
			       			if index >= 0
			       				prev = elem.prev
			       				newElem = {prev: prev, value: value, next: k}
			       				@_linsert key, keyinfo, newElem, index, true, elem, ->
			       					cb 'OK'
			       			else
			       				next = elem.next
			       				newElem = {prev: k, value: value, next: next}
			       				@_linsert key, keyinfo, newElem, index, false, elem, ->
			       					cb 'OK'
		return
	return
