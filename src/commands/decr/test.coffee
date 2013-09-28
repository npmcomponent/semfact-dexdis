describe 'DECR', ->
	it 'should set the value of the key to zero if the key does not exist and decrement it', (done) ->
		dexdis.decr 'decr', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal -1
			dexdis.get 'decr', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal -1
				do done
	it 'should decrement the value of the key by one', (done) ->
		dexdis.set 'decr', 43, (err) ->
			expect(err).to.be.null
			dexdis.decr 'decr', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				dexdis.get 'decr', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 42
					do done
