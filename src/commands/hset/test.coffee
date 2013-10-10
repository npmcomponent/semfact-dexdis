describe 'HSET', ->
	it 'should return 1 if the key does not exist', (done) ->
		dexdis.hset 'hset', 'test', 42, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			do done
	it 'should return 0 if the field exists', (done) ->
		dexdis.hset 'hset', 'test', 42, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.hset 'hset', 'test', 23, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				do done
	it 'should return an error if the field is not a hash', (done) ->
		dexdis.set 'hset', 42, (err) ->
			expect(err).to.be.null
			dexdis.hset 'hset', 'test', 42, (err, res) ->
				expect(err).to.be.an Error
