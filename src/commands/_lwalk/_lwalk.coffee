_lwalk: (key, cond, func, left, cb) ->
	{keys, list} = @_stores
	store = list
	
	walk = (index, elem, key) ->
		if cond? && cond index, elem
			cb index, elem, key
		else
			if func?
				func index, elem, key
			if left
				if not elem.next?
					cb null
					return
				else
					key = elem.next
			else
				if not elem.prev?
					cb null
					return
				else
					key = elem.prev
			elem = store.get key
			elem.onsuccess = ->
				if elem.result is undefined
					cb null
					return
				else
					if left
						index = index+1
					else
						index = index-1
					walk index, elem.result, key
				return
		return
	
	@_checkttl key, 'list', (list) ->
		if list is undefined
			cb null
		else
			if left
				if list.first is null
					cb null
					return
				else
					ekey = list.first
					start = 0
			else
				if list.last is null
					cb null
				else
					ekey = list.last
					start = -1
			first = store.get ekey
			first.onsuccess = ->
				if first.result is undefined
					cb null
					return
				else
					walk start, first.result, ekey
				return
		return
	return
