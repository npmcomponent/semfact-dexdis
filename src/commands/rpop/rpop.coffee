rpop: (key, cb) ->
	@_listpop key, false, cb
