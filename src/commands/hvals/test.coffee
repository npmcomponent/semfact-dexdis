describe 'HVALS', ->
	it 'should return an empty array if the hash does not exist', (done) ->
		dexdis.hvals 'hvals', (err, res) ->
			expect(err).to.be.null
			expect(res).to.eql []
			do done
	it 'should return the values of the hash', (done) ->
		dexdis.hset 'hvals', 'test1', 42, (err) ->
			expect(err).to.be.null
			dexdis.hset 'hvals', 'test2', 23, (err) ->
				expect(err).to.be.null
				dexdis.hvals 'hvals', (err, res) ->
					expect(err).to.be.null
					expect(res).to.eql [23, 42]
					do done
