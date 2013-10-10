describe 'HGETALL', ->
	it 'should return an empty array if the key does not exist', (done) ->
		dexdis.hgetall 'hgetall', (err, res) ->
			expect(err).to.be.null
			expect(res).to.eql []
			do done
	it 'should return the keys and values if the key is a hash', (done) ->
		dexdis.hset 'hgetall', 'test1', 42, (err) ->
			expect(err).to.be.null
			dexdis.hset 'hgetall', 'test2', 23, (err) ->
				expect(err).to.be.null
				dexdis.hgetall 'hgetall', (err, res) ->
					expect(err).to.be.null
					expect(res).to.eql ['test1', 42, 'test2', 23]
					do done
