describe 'LINSERT', ->
	it 'should return null if the key does not exist', (done) ->
		dexdis.linsert 'linsert', 0, 'foo', (err, res) ->
			expect(err).to.be.null
			expect(res).to.be.null
			do done
	it 'should return null if the index is out of range', (done) ->
		dexdis.lpush 'linsert', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.linsert 'linsert', 42, 'foo', (err, res) ->
				expect(err).to.be.null
				expect(res).to.be.null
				do done
	it 'should insert a value at an index into a list', (done) ->
		dexdis.lpush 'linsert', 'baz', 'foo', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 2
			dexdis.linsert 'linsert', 1, 'bar', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'OK'
				dexdis.lindex 'linsert', 0, (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'foo'
					dexdis.lindex 'linsert', 1, (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 'bar'
						dexdis.lindex 'linsert', 2, (err, res) ->
							expect(err).to.be.null
							expect(res).to.equal 'baz'
							do done
	it 'should insert a value at a negative index into a list', (done) ->
		dexdis.lpush 'linsert', 'bar', 'foo', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 2
			dexdis.linsert 'linsert', -1, 'baz', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'OK'
				dexdis.lindex 'linsert', 0, (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'foo'
					dexdis.lindex 'linsert', 1, (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 'bar'
						dexdis.lindex 'linsert', 2, (err, res) ->
							expect(err).to.be.null
							expect(res).to.equal 'baz'
							do done
