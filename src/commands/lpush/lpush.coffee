lpush: (key, values..., cb) ->
	@_listpush key, values, true, cb
