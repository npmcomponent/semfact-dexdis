linsert: (key, index, value, cb) ->
	{keys, list} = @_stores
	insert = (keyinfo, i, elem, k, prevNext, newElem, prev) ->
		putNewElem = list.add newElem
		putNewElem.onsuccess = (ev) ->
			newElemKey = ev.target.result
			if (i is 0) or (i is -keyinfo.len) 
				keyinfo.first = newElemKey
			if (i is keyinfo.len) or (i is -1)
				keyinfo.last = newElemKey
			keyinfo.len += 1
			putlist = keys.put keyinfo, key
			putlist.onsuccess = ->
				if prev
					elem.prev = newElemKey
				else
					elem.next = newElemKey
				putelem = list.put elem, k
				putelem.onsuccess = ->
					if prevNext?
						getPrevNextElem = list.get prevNext
						getPrevNextElem.onsuccess = ->
							prevNextElem = getPrevNextElem.result
							if prev
								prevNextElem.next = newElemKey
							else
								prevNextElem.prev = newElemKey
							putPrevNext = list.put prevNextElem, prevNext
							putPrevNext.onsuccess = ->
								cb 'OK'
							return
					else
						cb 'OK'
				return
			return
		return
		
	@_checkttl key, 'list', (keyinfo) =>
		if keyinfo is undefined
			cb null
			return
		else
			@_lwalk key,
			       (i, elem) ->
			       		i is index
			       ,
			       null,
			       index >= 0,
			       (i, elem, k) ->
			       		if i is null
			       			cb null
			       			return
			       		else
			       			if index >= 0
			       				prev = elem.prev
			       				newElem = {prev: prev, value: value, next: k}
			       				insert keyinfo, i, elem, k, prev, newElem, true
			       			else
			       				next = elem.next
			       				newElem = {prev: k, value: value, next: next}
			       				insert keyinfo, i, elem, k, next, newElem, false
		return
	return
