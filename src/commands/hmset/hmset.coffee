hmset: (key, args..., cb) ->
	if args.length % 2 isnt 0
		@onerror new Error errs.wrongargs
		return
	@_checkttl key, 'hash', (keyinfo) =>
		for field, i in args by 2
			value = args[i+1]
			@_hset key, field, value, ->
			if i is args.length - 2
				cb 'OK'
		return
	return
