lpop: (key, cb) ->
	@_listpop key, true, cb
