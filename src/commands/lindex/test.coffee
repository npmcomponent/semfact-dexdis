describe 'LINDEX', ->
	it 'should return null if the key does not exist', (done) ->
		dexdis.lindex 'lindex', 0, (err, res) ->
			expect(err).to.be.null
			expect(res).to.be.null
			do done
	it 'should return null if the index is out of range', (done) ->
		dexdis.lpush 'lindex', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.lindex 'lindex', 42, (err, res) ->
				expect(err).to.be.null
				expect(res).to.be.null
				do done
	it 'should return the value at the index of the list', (done) ->
		dexdis.lpush 'lindex', 'test', (err) ->
			expect(err).to.be.null
			dexdis.lindex 'lindex', 0, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				do done
	it 'should return the value at the index of the list with negative index', (done) ->
		dexdis.lpush 'lindex', 'test', (err) ->
			expect(err).to.be.null
			dexdis.lindex 'lindex', -1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				do done
