_lwalk: (keyinfo, cond, func, left, cb) ->
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
	
	if left
		if keyinfo.first is null
			cb null
			return
		else
			ekey = keyinfo.first
			start = 0
	else
		if keyinfo.last is null
			cb null
		else
			ekey = keyinfo.last
			start = -1
	first = store.get ekey
	first.onsuccess = ->
		if first.result is undefined
			cb null
			return
		else
			walk start, first.result, ekey
		return
