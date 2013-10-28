_listpop: (key, left, cb) ->
	{keys, list} = @_stores
	@_checkttl key, 'list', (keyinfo) ->
		if keyinfo is undefined
			cb null
			return
		else
			value = null
			dellist = ->
				del = keys.delete key
				del.onsuccess = cb value
				return
			if left
				elemKey = keyinfo.first
			else
				elemKey = keyinfo.last
			if elemKey isnt null
				get = list.get elemKey
				get.onsuccess = ->
					delelem = list.delete elemKey
					delelem.onsuccess = ->
						value = get.result.value
						if left
							keyinfo.first = get.result.next
						else
							keyinfo.last = get.result.prev
						keyinfo.len -= 1
						put = keys.put keyinfo, key
						put.onsuccess = ->
							if keyinfo.len is 0
								dellist()
							else
								cb value
							return
						return
					return
			else
				dellist()
		return
	return
