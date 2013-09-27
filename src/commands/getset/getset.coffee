getset: (key, value, cb) ->
	@get key, (val) =>
		@set key, value, ->
			cb val
