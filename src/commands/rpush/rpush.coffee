rpush: (key, values..., cb) ->
	@_listpush key, values, false, cb
