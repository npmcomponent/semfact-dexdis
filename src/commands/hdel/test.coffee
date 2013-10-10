describe 'HDEL', ->
	it 'should return 0 if the key does not exist', (done) ->
		dexdis.hdel 'hdel', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
	it 'should ignore fields that do not exist', (done) ->
		dexdis.hset 'hdel', 'test1', 42, (err) ->
			expect(err).to.be.null
			dexdis.hset 'hdel', 'test2', 23, (err) ->
				expect(err).to.be.null
				dexdis.hdel 'hdel', 'test1', 'test4', 'test2', 'test3', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					dexdis.hget 'hdel', 'test1', (err, res) ->
						expect(err).to.be.null
						expect(res).to.be.null
						do done
	it 'should do nothing if all fields do not exist', (done) ->
		dexdis.hset 'hdel', 'test', 42, (err) ->
			expect(err).to.be.null
			dexdis.hdel 'hdel', 'foo', 'bar', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				do done
