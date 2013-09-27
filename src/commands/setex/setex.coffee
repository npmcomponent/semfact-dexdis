setex: (key, secs, value, cb) ->
	@set key, value, =>
		@expire key, secs, ->
			cb 'OK'
