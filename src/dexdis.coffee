
errs =
	transaction:   'Operation not allowed during transaction'
	wrongtype:     'Operation against a key holding the wrong kind of value'
	notransaction: 'Operation not allowed without transaction'
	notsupported:  'Operation not supported'
	toomuchop:     'Operation with too much operands'

# calculate hamming weight (for BITCOUNT command)
# see http://jsperf.com/hamming-weight/4
hamming = (x) ->
	m1 = 0x55555555
	m2 = 0x33333333
	m4 = 0x0f0f0f0f
	x -= (x >> 1) & m1
	x = (x & m2) + ((x >> 2) & m2)
	x = (x + (x >> 4)) & m4
	x += x >>  8
	x += x >> 16
	x & 0x7f

class DexdisCommands
	
	constructor: (trans) ->
		stores  = ['keys', 'values']
		@_stores = {}
		for s in stores
			@_stores[s] = trans.objectStore s
	
	# check if specific key is expired and return keyinfo
	_checkttl: (key, cb) ->
		{keys, values} = @_stores
		get = keys.get key
		get.addEventListener 'success', ->
			keyinfo = get.result
			if keyinfo?.expire?
				if Date.now() > keyinfo.expire
					del = keys.delete key
					del.addEventListener 'success', ->
						cb undefined, true
					values.delete key
				else
					cb keyinfo, false
			else
				cb keyinfo, false
		return
	
	# get a value modify it and save it again
	_map: (key, cb, f) ->
		{keys, values} = @_stores
		value = null
		@_checkttl key, (keyinfo) ->
			if keyinfo?
				if keyinfo.type is 'simple'
					get = values.get key
					get.addEventListener 'success', ->
						value = f get.result
						put = values.put value, key
						put.addEventListener 'success', ->
							cb value
				else
					cb new Error errs.wrongtype
			else
				keyinfo =
					type: 'simple'
				keys.put keyinfo, key
				put = values.put value, key
				put.addEventListener 'success', ->
					cb value
		return
	
	# get ttl of key with optional mapping function f
	_ttlmap: (key, cb, f) ->
		@_checkttl key, (keyinfo) ->
			if keyinfo isnt undefined
				ret = -1
				if keyinfo.expire?
					ret = keyinfo.expire - Date.now()
					ret = f ret if f?
				cb ret
			else
				cb -2
		return
	
	# set ttl of key with optional mapping function f
	_expiremap: (key, cb, f) ->
		keys = @_stores.keys
		@_checkttl key, (keyinfo) ->
			if keyinfo isnt undefined
				keyinfo.expire = f keyinfo.expire
				r = keys.put keyinfo, key
				r.addEventListener 'success', ->
					cb 1
			else
				cb 0
		return
	
	# get value as string and throw error if it is not a string or number
	_getstr: (key, cb) ->
		@get key, (val) ->
			if val?
				type = typeof val
				if type isnt 'string'
					if type is 'number'
						val = '' + val
					else
						throw new Error errs.wrongtype
			else
				val = ''
			cb val
	
	append: (key, val, cb) ->
		l = 0
		cbmap = ->
			cb l
		@_map key, cbmap, (x) ->
			ret = x + val
			l = ret.length
			ret
	
	bitcount: (key, range..., cb) ->
		@_getstr key, (val) ->
			cb hamming val.substring.apply val, range
	bitop: (op, dest, srcs..., cb) ->
		f    = null
		init = 0
		switch op.toUpperCase()
			when 'NOT'
				f = (x,y) -> ~ y
				if srcs.length > 1
					throw new Error errs.toomuchop
			when 'AND'
				f    = (x,y) -> x & y
				init = -1
			when 'OR'
				f = (x,y) -> x | y
			when 'XOR'
				f = (x,y) -> x ^ y
		if f is null
			throw new Error errs.notsupported
		vals = []
		i = 0
		next = (v) =>
			if v isnt undefined
				vals.push v
			i++
			if i > srcs.length
				val = vals.reduce f, init
				@set dest, val, ->
					cb (''+val).length
				return
			key = srcs[i-1]
			@get key, next
		do next
	
	decr: (key, cb) ->
		@decrby key, 1, cb
	
	decrby: (key, dec, cb) ->
		@incrby key, -dec, cb
	
	del: (dels..., cb) ->
		{keys, values} = @_stores
		if dels.length is 0
			cb 0
			return
		count = 0
		for k, i in dels
			@_checkttl k, (keyinfo) ->
				if keyinfo?
					count++
					keys.delete k
					del = values.delete k
					if i is dels.length
						del.addEventListener 'success', ->
							cb count
		return
	
	exists: (key, cb) ->
		@_checkttl key, (keyinfo) ->
			if keyinfo?
				cb 1
			else
				cb 0
	
	expire: (key, seconds, cb) ->
		@_expiremap key, cb, ->
			Date.now() + seconds * 1000
	
	expireat: (key, tstamp, cb) ->
		@_expiremap key, cb, ->
			tstamp * 1000
	
	flushall: (cb) ->
		{keys, values} = @_stores
		do keys.clear
		do values.clear
		cb 'OK'
		return
	
	get: (key, cb) ->
		{keys, values} = @_stores
		@_checkttl key, (keyinfo) ->
			if keyinfo is undefined
				cb null
			else if keyinfo.type isnt 'simple'
				throw new Error errs.wrongtype
			else
				get = values.get key
				get.addEventListener 'success', ->
					cb get.result
		return
	
	getbit: (key, offset, cb) ->
		@_getstr key, (val) ->
			if offset > 31
				cb 0
			else
				cb (val >>> offset) & 1
	
	getrange: (key, start, end, cb) ->
		@_getstr key, (val) ->
			cb val.substring start, end 
	
	getset: (key, value, cb) ->
		@get key, (val) =>
			@set key, value, ->
				cb val
	
	incr: (key, cb) ->
		@incrby key, 1, cb
	
	incrby: (key, inc, cb) ->
		@_map key, cb, (x) ->
			x + inc
	
	persist: (key, cb) ->
		keys = @_stores.keys
		@_checkttl key, (keyinfo) ->
			if keyinfo isnt undefined
				ret = 0
				if keyinfo.expire?
					delete keyinfo.expire
					ret = 1
				r = keys.put keyinfo, key
				r.addEventListener 'success', ->
					cb ret
			else
				cb 0
		return
	
	pexpire: (key, milliseconds, cb) ->
		@_expiremap key, cb, ->
			Date.now() + milliseconds
	
	pexpireat: (key, tstamp, cb) ->
		@_expiremap key, cb, ->
			tstamp
	
	pttl: (key, cb) ->
		@_ttlmap key, cb
	
	set: (key, value, cb) ->
		{keys, values} = @_stores
		keyinfo =
			type: 'simple'
		keys.put keyinfo, key
		put = values.put value, key
		put.addEventListener 'success', ->
			cb 'OK'
		return
	
	setbit: (key, offset, value, cb) ->
		@_getstr key, (val) =>
			value  &= 1
			mask    = 1 << offset
			newval  = (val & ~mask) | (value << offset)
			@set key, newval, ->
				if (val & mask) isnt 0
					cb 1
				else
					cb 0
	
	setnx: (key, value, cb) ->
		@_checkttl key, (keyinfo) =>
			if keyinfo?
				cb 0
			else
				@set key, value, ->
					cb 1
		return
	
	strlen: (key, cb) ->
		@_getstr key, (val) ->
			cb val.length
	
	ttl: (key, cb) ->
		@_ttlmap key, cb, (x) ->
			Math.round x / 1000

DexdisCommands.cmds = Object.keys(DexdisCommands::).filter (x) ->
	x[0] isnt '_'

class DexdisDb
	
	# get indexeddb transaction with keys and values stores
	_transaction: (cb, mode = 'readwrite') ->
		trans = @db.transaction ['keys', 'values'], mode
		trans.addEventListener 'error', (e) ->
			cb e if cb?
		trans.addEventListener 'abort', (e) ->
			cb new Error 'Transaction Aborted' if cb?
		trans

class Dexdis extends DexdisDb
	
	constructor: (db = 1) ->
		@select db
	
	# execute dexdis command
	_cmd: (cmd, args, cb, mode) ->
		ret = null
		save = (x) ->
			ret = x
			return
		trans = @_transaction cb, mode
		trans.addEventListener 'complete', ->
			cb null, ret if cb?
		cmds = new DexdisCommands trans
		cmds[cmd].apply cmds, args.concat [save]
		return
	
	ping: (cb) ->
		cb null, 'PONG' if cb?
		this
	
	echo: (msg, cb) ->
		cb null, msg if cb?
		this
	
	select: (db, cb) ->
		if @db is null
			cb new Error errs.transaction
			return
		r = indexedDB.open db, 1
		r.addEventListener 'upgradeneeded', (e) ->
			console.log 'upgrade'
			db = e.target.result
			db.createObjectStore 'keys'
			db.createObjectStore 'values'
		r.addEventListener 'success', (e) =>
			@db = e.target.result
			cb null if cb?
		this
	
	quit: (cb) ->
		@db.close() if @db?
		cb null if cb?
		this
	
	multi: (cb) ->
		new DexdisTransaction @db
	
	exec: (cb) ->
		cb new Error errs.notransaction
		this
	
	discard: (cb) ->
		cb new Error errs.notransaction
		this
	
	for cmd in DexdisCommands.cmds
		do (cmd) =>
			@::[cmd] = (args..., cb) ->
				if typeof cb is 'function'
					@_cmd cmd, args, cb
				else
					args = args.concat [cb]
					@_cmd cmd, args, ->
				this

class DexdisTransaction extends DexdisDb
	
	constructor: (@db) ->
		@buffer = []
	
	_buffercmd: (cmd, args) ->
		@buffer.push
			cmd:  cmd
			args: args
	
	exec: (cb) ->
		trans  = @_transaction cb
		cmds   = new DexdisCommands trans
		buffer = @buffer
		i      = 0
		values = []
		next = (val) ->
			if val isnt undefined
				values.push val
			i++
			if i > buffer.length
				return
			b = buffer[i-1]
			cmds[b.cmd].apply cmds, b.args.concat [next]
		trans.addEventListener 'complete', ->
			cb null, values
		trans.addEventListener 'error', (e) ->
			cb e
		next()
		return
	
	discard: (cb) ->
		@buffer = []
		@trans.abort()
	
	for cmd in DexdisCommands.cmds
		do (cmd) =>
			@::[cmd] = (args...) ->
				@_buffercmd cmd, args
				this

window.Dexdis = Dexdis
window.DexdisTransaction = DexdisTransaction
window.DexdisCommands = DexdisCommands

# testing
window.d   = new Dexdis()
window.log = -> console.log arguments
