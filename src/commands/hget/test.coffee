describe 'HGET', ->
	it 'should return null if the key does not exist', (done) ->
		dexdis.hget 'hget', 'test', (err, res) ->
			expect(err).to.be.null
			expect(res).to.be.null
			do done
	it 'should return null if the field does not exist', (done) ->
		dexdis.hset 'hget', 'foo', 42, (err) ->
			expect(err).to.be.null
			dexdis.hget 'hget', 'bar', (err, res) ->
				expect(err).to.be.null
				expect(res).to.be.null
				do done
	it 'should return the value if the field exists', (done) ->
		dexdis.hset 'hget', 'test', 42, (err) ->
			expect(err).to.be.null
			dexdis.hget 'hget', 'test', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				do done
