lget: (key, leftIndex, rightIndex, cb) ->
	@_checkttl key, 'list', (keyinfo) =>
		if keyinfo is undefined
			cb null
			return
		else
			values = []
			li = leftIndex
			ri = rightIndex
			len = keyinfo.len
			if leftIndex >= 0
				left = true
				if (rightIndex >= 0) && (rightIndex < leftIndex)
					left = false
					li = leftIndex - len
					ri = rightIndex - len
				if rightIndex < 0
					if leftIndex - len > rightIndex
						left = false
						li = leftIndex - len
					else
						ri = rightIndex + len
			else
				left = false
				if rightIndex >= 0
					if rightIndex > leftIndex + len
						left = true
						li = leftIndex + len
					else
						ri = rightIndex - len
				if (rightIndex < 0) && (rightIndex > leftIndex)
					left = true
					li = leftIndex + len
					ri = rightIndex + len
			leftIndex = li
			rightIndex = ri
			@_lwalk keyinfo,
			       (index, elem) ->
			       		if left
			       			stop = index is len
			       		else
			       			stop = index is -len-1
			       		return stop
			       ,
			       (i, elem, k) -> 
			       		if left
			       			if i >= leftIndex && i <= rightIndex
			       				values.push elem.value
			       		else
			       			if i >= rightIndex && i <= leftIndex
			       				values.push elem.value
			       ,
			       left,
			       (i, elem, k) ->
			       		cb values
	return
