describe 'HMGET', ->
	it 'should get fields and their values if the key exists', (done) ->
		dexdis.hmset 'hmget', 'foo', 42, 'bar', 23, (err) ->
			expect(err).to.be.null
			dexdis.hmget 'hmget', 'foo', 'bar', (err, res) ->
				expect(err).to.be.null
				expect(res).to.eql [42, 23]
				do done
	it 'should return null if fields do not exist', (done) ->
		dexdis.hmset 'hmget', 'foo', 42, 'bar', 23, (err) ->
			expect(err).to.be.null
			dexdis.hmget 'hmget', 'foo', 'test', 'bar', (err, res) ->
				expect(err).to.be.null
				expect(res).to.eql [42, null, 23]
				do done
