ttl: (key, cb) ->
	@_ttlmap key, cb, (x) ->
		Math.round x / 1000
