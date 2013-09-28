describe 'INCR', ->
	it 'should set the value of the key to zero if the key does not exist and increment it', (done) ->
		dexdis.incr 'incr', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.get 'incr', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				do done
	it 'should increment the value of the key by one', (done) ->
		dexdis.set 'incr', 41, (err) ->
			expect(err).to.be.null
			dexdis.incr 'incr', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				dexdis.get 'incr', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 42
					do done
