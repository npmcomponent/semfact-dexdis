hmget: (key, args..., cb) ->
	@_checkttl key, 'hash', (keyinfo) =>
		ret = []
		cnt = 0
		for field, i in args
			do (field, i) =>
				@_hget key, field, (res) ->
					ret[i] = res
					cnt++
					if cnt is args.length
						cb ret
		return
	return
