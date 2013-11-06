_lmultiindex: (keyinfo, leftIndex, rightIndex, cb) ->
	li = leftIndex
	ri = rightIndex
	len = keyinfo.len
	if leftIndex >= 0
		left = true
		if (rightIndex >= 0) && (rightIndex < leftIndex)
			left = false
			ri = leftIndex - len
			li = rightIndex - len
		if rightIndex < 0
			if leftIndex - len > rightIndex
				left = false
				ri = leftIndex - len
				li = rightIndex
			else
				ri = rightIndex + len
	else
		ri = leftIndex
		li = rightIndex
		left = false
		if rightIndex >= 0
			if rightIndex > leftIndex + len
				left = true
				li = leftIndex + len
				ri = rightIndex
			else
				li = rightIndex - len
		if (rightIndex < 0) && (rightIndex > leftIndex)
			left = true
			li = leftIndex + len
			ri = rightIndex + len
	cb li, ri, left
