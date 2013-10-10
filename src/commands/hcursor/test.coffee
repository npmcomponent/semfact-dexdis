describe 'HCURSOR', ->
	it 'should return null if the key does exist', (done) ->
		dexdis.hcursor 'hcursor', (err, res) ->
			expect(err).to.be.null
			expect(res).to.be.null
			do done
	it 'should return a cursor if the key is a hash', (done) ->
		dexdis.hset 'hcursor', 'foobar', 42, (err) ->
			expect(err).to.be.null
			dexdis.hcursor 'hcursor', (err, res) ->
				expect(err).to.be.null
				expect(res).to.be.an.instanceof IDBCursor
				do done
