describe 'LSET', ->
	it 'should return an error if the key does not exist', (done) ->
		dexdis.lset 'lset', 0, 'test', (err) ->
			expect(err).to.be.an.instanceof Error
			do done
	it 'should return an error if the index is out of range', (done) ->
		dexdis.lpush 'lset', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.lset 'lset', 42, (err) ->
				expect(err).to.be.an.instanceof Error
				do done
	it 'should set the value at the index of the list', (done) ->
		dexdis.lpush 'lset', 'baz', 'bar', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.lset 'lset', 1, 'test', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'OK'
				dexdis.lindex 'lset', 1, (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'test'
					do done
