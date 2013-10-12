describe 'HMSET', ->
	it 'should set all fields and their values if the key does not exist', (done) ->
		dexdis.hmset 'hmset', 'foo', 42, 'bar', 23, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 'OK'
			dexdis.hget 'hmset', 'foo', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				dexdis.hget 'hmset', 'bar', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 23
					do done
	it 'should set all fields and their values if the key exists', (done) ->
		dexdis.hset 'hmset', 'foo', 1, (err) ->
			expect(err).to.be.null
			dexdis.hmset 'hmset', 'foo', 42, 'bar', 23, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'OK'
				dexdis.hget 'hmset', 'foo', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 42
					dexdis.hget 'hmset', 'bar', (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 23
						do done
	it 'should return an error if the arguments are not pairwise field/values', (done) ->
		dexdis.hmset 'hmset', 'foo', 42, 'bar', (err) ->
			expect(err).to.be.an.instanceof Error
			do done
	it 'should return an error if the value of the key is not a hash', (done) ->
		dexdis.set 'hmset', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.hmset 'hmset', 'foo', 42, 'bar', (err) ->
				expect(err).to.be.an.instanceof Error
				do done
