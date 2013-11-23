describe 'LGET', ->
	it 'should return null if the key does not exist', (done) ->
		dexdis.lget 'lget', 0, 0, (err, res) ->
			expect(err).to.be.null
			expect(res).to.be.null
			do done
	it 'should set left or right to 0 or llen if the index is out of range', (done) ->
		dexdis.lpush 'lget', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.lget 'lget', 0, 42, (err, res) ->
				expect(err).to.be.null
				expect(res).to.eql ['foo']
				do done
	it 'should return the values of the list starting with left and ending with right', (done) ->
		dexdis.lpush 'lget', 'baz', 'bar', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.lget 'lget', 0, 1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.eql ['foo', 'bar']
				do done
	it 'should return the values of the list starting with left and ending with right with negative indexes', (done) ->
		dexdis.lpush 'lget', 'baz', 'bar', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.lget 'lget', -1, -2, (err, res) ->
				expect(err).to.be.null
				expect(res).to.eql ['baz', 'bar']
				do done
