_listpush: (key, values, left, cb) ->
	if values.length is 0
		cb 0
		return
	{keys, list} = @_stores
	store = list
	@_checkttl key, 'list', (keyinfo) =>
		append = (value, cb) =>
			if left
				elem = {prev: null, value: value, next: keyinfo.first}
				index = 0
			else
				elem = {prev: keyinfo.last, value: value, next: null}
				index = keyinfo.len
			
			@_lins key, keyinfo, elem, index, left, null, cb
		add = ->
			i = 0
			next = ->
				append values[i], ->
					i++
					if i is values.length
						cb keyinfo.len
					else
						next()
			do next
		if keyinfo is undefined
			keyinfo =
				type: 'list'
				first: null
				last: null
				len: 0
			put = keys.put keyinfo, key
			put.onsuccess = add
		else
			add()
	return
