_linsert: (key, keyinfo, elem, index, moveRight, neighbor, cb) ->
	{keys, list} = @_stores
	editNeighbor = (neighborElem, elemKey, left, cb)->
		if left
			neighbor = elem.prev
			neighborElem.next = elemKey
		else
			neighbor = elem.next
			neighborElem.prev = elemKey
		putNeighbor = list.put neighborElem, neighbor
		putNeighbor.onsuccess = cb
	getEditNeighbor = (neighbor, elemKey, left, cb) ->
		if neighbor is null
			cb()
		else
			getNeighbor = list.get neighbor
			getNeighbor.onsuccess = ->
				editNeighbor getNeighbor.result, elemKey, left, cb
			return
	putNewElem = list.add elem
	putNewElem.onsuccess = (ev) ->
		elemKey = ev.target.result
		if (index is 0) or (index is -keyinfo.len) 
			keyinfo.first = elemKey
		if (index is keyinfo.len) or (index is -1)
			keyinfo.last = elemKey
		if keyinfo.len is 0
			keyinfo.first = elemKey
			keyinfo.last  = elemKey
		keyinfo.len += 1
		putlist = keys.put keyinfo, key
		putlist.onsuccess = ->
			if moveRight
				rightNeighbor = neighbor
			else
				leftNeighbor = neighbor
			c = ->
				if leftNeighbor?
					editNeighbor leftNeighbor, elemKey, true, ->
						cb keyinfo.len
				else
					getEditNeighbor elem.prev, elemKey, true, ->
						cb keyinfo.len
			if rightNeighbor?
				editNeighbor rightNeighbor, elemKey, false, c
			else
				getEditNeighbor elem.next, elemKey, false, c
		return
	return
