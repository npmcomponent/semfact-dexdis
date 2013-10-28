lpop: (key, cb) ->
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
			if keyinfo.first isnt null
				get = list.get keyinfo.first
				get.onsuccess = ->
					delfirst = list.delete keyinfo.first
					delfirst.onsuccess = ->
						keyinfo.first = get.result.next
						value = get.result.value
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
