_lwalk: (key, cond, func, cb) ->
	{keys, list} = @_stores
	store = list
	walk = (index, elem, key) ->
		if cond? && cond index, elem
			cb index, elem, key
		else
			if func?
				func index, elem, key
			if not elem.next?
				cb null
			else
				key = elem.next
				elem = store.get key
				elem.onsuccess = ->
					if elem.result is undefined
						cb null
					else
						walk index+1, elem.result, key
	@_checkttl key, 'list', (list) ->
		if (list is undefined) or (list.first is null)
			cb null
		else
			first = store.get list.first
			first.onsuccess = ->
				if first.result is undefined
					cb null
				else
					walk 0, first.result, list.first
	return
