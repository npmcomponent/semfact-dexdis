
class Dexdis
	
	errs =
		wrongtype: 'Operation against a key holding the wrong kind of value'
	
	constructor: (db = 1) ->
		@select db
	
	# get indexeddb transaction with keys and values stores
	_transaction: (cb, complete, mode = 'readwrite') ->
		if complete is undefined
			complete = (e) ->
				cb null if cb?
		trans  = @db.transaction ['keys', 'values'], mode
		keys   = trans.objectStore 'keys'
		values = trans.objectStore 'values'
		if complete?
			trans.addEventListener 'complete', complete
		trans.addEventListener 'error', (e) ->
			cb e if cb?
		trans.addEventListener 'abort', (e) ->
			cb new Error 'Transaction Aborted' if cb?
		return {trans, keys, values}
	
	# get keyinfo of key for manipulation
	_keyinfo: (key, cb, keycb) ->
		{keys, values} = @_transaction cb, null
		@_checkttl cb, key, keys, values, (keyinfo) ->
			keycb keyinfo, keys
	
	# get ttl of key with optional mapping function f
	_ttl: (key, cb, f = null) ->
		@_keyinfo key, cb, (keyinfo) ->
			if keyinfo isnt undefined
				ret = -1
				if keyinfo.expire?
					ret = keyinfo.expire - Date.now()
					ret = f ret if f?
				cb null, ret if cb?
			else
				cb null, -2 if cb?
		return
	
	# check if specific key is expired
	_checkttl: (cb, key, keys, values, cbttl) ->
		get = keys.get key
		get.addEventListener 'error', (e) ->
			cb e
		get.addEventListener 'success', (e) ->
			keyinfo = e.target.result
			if keyinfo?.expire?
				if Date.now() > keyinfo.expire
					rm = keys.delete key
					rm.addEventListener 'success', ->
						cbttl undefined, true
					values.delete key
				else
					cbttl keyinfo, false
			else
				cbttl keyinfo, false
		return
	
	# get a value modify it and save it again
	_map: (key, cb, f, complete) ->
		value = null
		if complete is undefined
			complete = ->
				cb null, value
		{keys, values} = @_transaction cb, complete, 'readwrite'
		@_checkttl cb, key, keys, values, (keyinfo) ->
			if keyinfo?
				if keyinfo.type is 'simple'
					get = values.get key
					get.addEventListener 'success', (e) ->
						value = f e.target.result
						values.put value, key
				else
					cb new Error errs.wrongtype
			else
				keyinfo =
					type: 'simple'
				keys.put keyinfo, key
		return
	
	ping: (cb) ->
		cb null, 'PONG' if cb?
		return
	
	echo: (msg, cb) ->
		cb null, msg if cb?
		return
	
	select: (db, cb) ->
		r = indexedDB.open db, 1
		r.addEventListener 'upgradeneeded', (e) ->
			console.log 'upgrade'
			db = e.target.result
			db.createObjectStore 'keys'
			db.createObjectStore 'values'
		r.addEventListener 'success', (e) =>
			@db = e.target.result
			cb null if cb?
		return
	
	quit: (cb) ->
		@db.close() if @db?
		cb null if cb?
		return
	
	flushall: (cb) ->
		{keys, values} = @_transaction cb
		do keys.clear
		do values.clear
		return
	
	set: (key, value, cb) ->
		{keys, values} = @_transaction cb
		keyinfo =
			type: 'simple'
		keys.put keyinfo, key
		values.put value, key
		return
	
	get: (key, cb) ->
		{keys, values} = @_transaction cb, null, 'readwrite'# 'readonly'
		@_checkttl cb, key, keys, values, (keyinfo) ->
			if keyinfo is undefined
				cb null, null
			else if keyinfo.type isnt 'simple'
				cb new Error errs.wrongtype
			else
				get = values.get key
				get.addEventListener 'error', cb
				get.addEventListener 'success', (e) ->
					cb null, e.target.result
		return
	
	del: (dels..., cb) ->
		count = 0
		{keys, values} = @_transaction cb, (e) ->
			cb null, count
		for k in dels
			@_checkttl cb, k, keys, values, (keyinfo) ->
				if keyinfo?
					count++
			keys.delete k
			values.delete k
		return
	
	expire: (key, seconds, cb) ->
		@_keyinfo key, cb, (keyinfo, keys) ->
			if keyinfo isnt undefined
				keyinfo.expire = Date.now() + seconds * 1000
				r = keys.put keyinfo, key
				r.addEventListener 'success', ->
					cb null, 1 if cb?
			else
				cb null, 0 if cb?
		return
	
	persist: (key, cb) ->
		@_keyinfo key, cb, (keyinfo, keys) ->
			if keyinfo isnt undefined
				ret = 0
				if keyinfo.expire?
					delete keyinfo.expire
					ret = 1
				r = keys.put keyinfo, key
				r.addEventListener 'success', ->
					cb null, ret if cb?
			else
				cb null, 0 if cb?
		return
	
	pttl: (key, cb) ->
		@_ttl key, cb
	
	ttl: (key, cb) ->
		@_ttl key, cb, (x) ->
			Math.round x / 1000
	
	exists: (key, cb) ->
		@_keyinfo key, cb, (keyinfo) ->
			if keyinfo?
				cb null, 1
			else
				cb null, 0
	
	incrby: (key, increment, cb) ->
		@_map key, cb, (value) ->
			value + increment
	
	incr: (key, cb) ->
		@incrby key, 1, cb
	
	decrby: (key, decrement, cb) ->
		@incrby key, -decrement, cb
	
	decr: (key, cb) ->
		@decrby key, 1, cb

window.Dexdis = Dexdis
