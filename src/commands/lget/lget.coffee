lget: (key, leftIndex, rightIndex, cb) ->
	@_checkttl key, 'list', (keyinfo) =>
		if keyinfo is undefined
			cb null
			return
		else
			values = []
			left = true
			@_lmultiindex keyinfo, leftIndex, rightIndex, (l, r, turn) ->
				leftIndex = l
				rightIndex = r
				left = turn
			@_lwalk keyinfo,
			       (index, elem) ->
			       		if left
			       			stop = index is keyinfo.len
			       		else
			       			stop = index is -keyinfo.len-1
			       		return stop
			       ,
			       (i, elem, k) -> 
			       		if i >= leftIndex && i <= rightIndex
			       			values.push elem.value
			       ,
			       left,
			       (i, elem, k) ->
			       		cb values
	return
