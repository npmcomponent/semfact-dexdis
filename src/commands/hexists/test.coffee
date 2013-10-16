describe 'HEXISTS', ->
	it 'should return 0 if the key does not exist', (done) ->
		dexdis.hexists 'hexists', 'test', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
	it 'should return 0 if the field does not exist', (done) ->
		dexdis.hset 'hexists', 'foo', 42, (err) ->
			expect(err).to.be.null
			dexdis.hexists 'hexists', 'bar', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				do done
	it 'should return 1 if the field exists', (done) ->
		dexdis.hset 'hexists', 'test', 42, (err) ->
			expect(err).to.be.null
			dexdis.hexists 'hexists', 'test', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				do done
