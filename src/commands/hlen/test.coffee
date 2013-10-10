describe 'HLEN', ->
	it 'should return 0 if the key does not exist', (done) ->
		dexdis.hlen 'hlen', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
	it 'should return the number of fields if the key is a hash', (done) ->
		dexdis.hset 'hlen', 'foo', 42, (err) ->
			expect(err).to.be.null
			dexdis.hset 'hlen', 'bar', 23, (err) ->
				expect(err).to.be.null
				dexdis.hlen 'hlen', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					do done
	it 'should return an error if the key is not a hash', (done) ->
		dexdis.set 'hlen', 'test', (err) ->
			expect(err).to.be.null
			dexdis.hlen 'hlen', (err) ->
				expect(err).to.be.an.instanceof Error
				do done
