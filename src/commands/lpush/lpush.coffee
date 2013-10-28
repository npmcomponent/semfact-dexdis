lpush: (key, values..., cb) ->
	if values.length is 0
		cb 0
		return
	{keys, list} = @_stores
	store = list
	@_checkttl key, 'list', (keyinfo) ->
		prepend = (value, cb) ->
			elem = {prev: null, value: value, next: keyinfo.first}
			put = store.add elem
			put.onsuccess = (ev) ->
				elemKey = ev.target.result
				keyinfo.len += 1
				updateList = ->
					keyinfo.first = elemKey
					putlist = keys.put keyinfo, key
					putlist.onsuccess = cb
				if keyinfo.first isnt null
					get = store.get keyinfo.first
					get.onsuccess = ->
						get.result.prev = elemKey
						putfirst = store.put get.result, keyinfo.first
						putfirst.onsuccess = updateList
				else
					keyinfo.last = elemKey
					updateList()
		add = ->
			i = 0
			next = ->
				prepend values[i], ->
					i++
					if i is values.length
						cb keyinfo.len
					else
						next()
			do next
			for value in values
				do (value) ->
					
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
