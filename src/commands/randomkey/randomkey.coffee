randomkey: (cb) ->
	{keys} = @_stores
	cnt = keys.count()
	cnt.onsuccess = ->
		rnd = Math.floor Math.random() * cnt.result
		cur = keys.openCursor()
		adv = false
		cur.onsuccess = ->
			cursor = cur.result
			if cursor?
				if adv or rnd is 0
					cb cursor.key
				else
					adv = true
					cursor.advance rnd
