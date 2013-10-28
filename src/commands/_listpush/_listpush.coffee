_listpush: (key, values, left, cb) ->
	if values.length is 0
		cb 0
		return
	{keys, list} = @_stores
	store = list
	@_checkttl key, 'list', (keyinfo) ->
		append = (value, cb) ->
			if left
				elem = {prev: null, value: value, next: keyinfo.first}
			else
				elem = {prev: keyinfo.last, value: value, next: null}
			put = store.add elem
			put.onsuccess = (ev) ->
				elemKey = ev.target.result
				keyinfo.len += 1
				updateList = ->
					if left
						keyinfo.first = elemKey
					else
						keyinfo.last = elemKey
					putlist = keys.put keyinfo, key
					putlist.onsuccess = cb
				if left
					edge = keyinfo.first
				else
					edge = keyinfo.last
				if edge isnt null
					get = store.get edge
					get.onsuccess = ->
						if left
							get.result.prev = elemKey
						else
							get.result.next = elemKey
						putedge = store.put get.result, edge
						putedge.onsuccess = updateList
				else
					if left
						keyinfo.last = elemKey
					else
						keyinfo.first = elemKey
					updateList()
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
