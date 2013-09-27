# calculate hamming weight (for BITCOUNT command)
# see http://jsperf.com/hamming-weight/4
hamming = (x) ->
	m1 = 0x55555555
	m2 = 0x33333333
	m4 = 0x0f0f0f0f
	x -= (x >> 1) & m1
	x = (x & m2) + ((x >> 2) & m2)
	x = (x + (x >> 4)) & m4
	x += x >>  8
	x += x >> 16
	x & 0x7f

bitcount: (key, range..., cb) ->
	@_getstr key, (val) ->
		cb hamming val.substring.apply val, range
