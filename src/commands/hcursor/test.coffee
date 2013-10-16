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
				expect(res.value).to.equal 42
				do done
	it 'should return a cursor with lower and upper bounds when bounds are set', (done) ->
		dexdis.hmset 'hcursor', 'a', 42, 'b', 23, (err) ->
			expect(err).to.be.null
			dexdis.hcursor 'hcursor', 'b', 'd', (err, res) ->
				expect(err).to.be.null
				expect(res).to.be.an.instanceof IDBCursor
				expect(res.value).to.equal 23
				dexdis.hcursor 'hcursor', 'a', 'a', (err, res) ->
					expect(err).to.be.null
					expect(res).to.be.an.instanceof IDBCursor
					expect(res.value).to.equal 42
					do done
	it 'should return a cursor with bounds set according to lower/upper in- or exclusive settings', (done) ->
		dexdis.hmset 'hcursor', 'a', 42, 'b', 23, (err) ->
			expect(err).to.be.null
			dexdis.hcursor 'hcursor', 'a', 'b', true, false, (err, res) ->
				expect(err).to.be.null
				expect(res).to.be.an.instanceof IDBCursor
				expect(res.value).to.equal 23
				dexdis.hcursor 'hcursor', 'a', 'b', false, true, (err, res) ->
					expect(err).to.be.null
					expect(res).to.be.an.instanceof IDBCursor
					expect(res.value).to.equal 42
					dexdis.hcursor 'hcursor', 'a', 'c', true, true, (err, res) ->
						expect(err).to.be.null
						expect(res).to.be.an.instanceof IDBCursor
						expect(res.value).to.equal 23
						dexdis.hcursor 'hcursor', 'a', 'a', false, false, (err, res) ->
							expect(err).to.be.null
							expect(res).to.be.an.instanceof IDBCursor
							expect(res.value).to.equal 42
							do done
	it 'should return an error if the wrong number of arguments are given', (done) ->
		dexdis.hset 'hcursor', 'test', 42, (err) ->
			expect(err).to.be.null
			dexdis.hcursor 'hcursor', 'a', (err) ->
				expect(err).to.be.an.instanceof Error
				dexdis.hcursor 'hcursor', 'a', 'b', true, (err) ->
					expect(err).to.be.an.instanceof Error
					dexdis.hcursor 'hcursor', 'a', 'b', true, false, 'foo', (err) ->
						expect(err).to.be.an.instanceof Error
						do done
