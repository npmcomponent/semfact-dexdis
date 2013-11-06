ldel: (key, leftIndex, rightIndex, cb) ->
	{keys, list} = @_stores
	@_checkttl key, 'list', (keyinfo) =>
		if keyinfo is undefined
			cb []
			return
		else
			left = true
			leftEdge = keyinfo.first
			rightEdge = keyinfo.last
			values = []
			@_lmultiindex keyinfo, leftIndex, rightIndex, (l, r, dir)->
				leftIndex = l
				rightIndex = r
				left = dir
			@_lwalk keyinfo,
			       (index, elem) ->
			       		if left
			       			stop = index is rightIndex + 1
			       		else
			       			stop = index is leftIndex - 1
			       		return stop
			       ,
			       (i, elem, k) -> 
			       		if i is leftIndex
			       			leftEdge = elem.prev
			       		if i is rightIndex
			       			rightEdge = elem.next
			       		if i >= leftIndex && i <= rightIndex
			       			values.push elem.value
			       			list.delete k
			       			keyinfo.len -= 1
			       ,
			       left,
			       (i, elem, k) ->
			       		putList = ->
			       			putlist = keys.put keyinfo, key
			       			putlist.onsuccess = ->
			       				cb values
			       				return
			       		getPutRight = (c)->
			       			getRight = list.get rightEdge
			       			getRight.onsuccess = ->
			       				getRight.result.prev = leftEdge
			       				putRight = list.put getRight.result, rightEdge
			       				putRight.onsuccess = c
			       		if (leftEdge is null) and (rightEdge is null)
			       			del = keys.delete key
			       			del.onsuccess  = ->
			       				cb values
			       				return
			       			return
			       		if leftEdge is null
			       			keyinfo.first = rightEdge
			       			getPutRight putList
			       			return
			       		else
			       			getLeft = list.get leftEdge
			       			getLeft.onsuccess = ->
			       				getLeft.result.next = rightEdge
			       				if rightEdge is null
			       					keyinfo.last = leftEdge
			       					putList()
			       					return
			       				else
			       					getPutRight putList
			       					return
		return
	return
