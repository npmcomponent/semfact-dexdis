describe 'HKEYS', ->
	it 'should return an empty array if the key does not exist', (done) ->
		dexdis.hkeys 'hkeys', (err, res) ->
			expect(err).to.be.null
			expect(res).to.eql []
			do done
	it 'should return the keys if the key is a hash', (done) ->
		dexdis.hset 'hkeys', 'test2', 42, (err) ->
			expect(err).to.be.null
			dexdis.hset 'hkeys', 'test1', 23, (err) ->
				expect(err).to.be.null
				dexdis.hkeys 'hkeys', (err, res) ->
					expect(err).to.be.null
					expect(res).to.eql ['test1', 'test2']
					do done
