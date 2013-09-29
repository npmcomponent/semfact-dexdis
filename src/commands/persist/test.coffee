describe 'PERSIST', ->
	it 'should remove the timeout from the given key', (done) ->
		dexdis.setex 'persist', 10, 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.persist 'persist', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				dexdis.ttl 'persist', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal -1
					do done
	it 'should return 0 if the key does not exist or has no timeout', (done) ->
		dexdis.persist 'persist', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
