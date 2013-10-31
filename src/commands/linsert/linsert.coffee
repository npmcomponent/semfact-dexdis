linsert: (key, index, value, cb) ->
	{keys, list} = @_stores
	insert = (prevNext, prev) ->
		putNewElem = list.add newElem
		putNewElem.onsuccess = (ev) ->
			newElemKey = ev.target.result
			keyinfo.len += 1
			putlist = keys.put keyinfo, key
			putlist.onsuccess = ->
				if prev
					elem.prev = newElemKey
				else
					elem.next = newElemKey
				putelem = list.put elem, k
				putelem.onsuccess = ->
					if prev
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
			       				putNewElem = list.add newElem
			       				putNewElem.onsuccess = (ev) ->
			       					newElemKey = ev.target.result
			       					keyinfo.len += 1
			       					putlist = keys.put keyinfo, key
			       					putlist.onsuccess = ->
			       						elem.prev = newElemKey
			       						putelem = list.put elem, k
			       						putelem.onsuccess = ->
			       							if prev?
			       								getPrevElem = list.get prev
			       								getPrevElem.onsuccess = ->
			       									prevElem = getPrevElem.result
			       									prevElem.next = newElemKey
			       									putPrev = list.put prevElem, prev
			       									putPrev.onsuccess = ->
			       										cb 'OK'
			       									return
			       							else
			       								cb 'OK'
			       						return
			       					return
			       				return
			       			else
			       				next = elem.next
			       				newElem = {prev: k, value: value, next: next}
			       				putNewElem = list.add newElem
			       				putNewElem.onsuccess = (ev) ->
			       					newElemKey = ev.target.result
			       					keyinfo.len += 1
			       					putlist = keys.put keyinfo, key
			       					putlist.onsuccess = ->
			       						elem.next = newElemKey
			       						putelem = list.put elem, k
			       						putelem.onsuccess = ->
			       							if next?
			       								getNextElem = list.get next
			       								getNextElem.onsuccess = ->
			       									nextElem = getNextElem.result
			       									nextElem.prev = newElemKey
			       									putNext = list.put nextElem, next
			       									putNext.onsuccess = ->
			       										cb 'OK'
			       									return
			       							else
			       								cb 'OK'
			       						return
			       					return
			       				return
		return
	return
