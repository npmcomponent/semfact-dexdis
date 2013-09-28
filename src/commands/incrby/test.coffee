describe 'INCRBY', ->
	it 'should set the value of the key to zero if the key does not exist and increment it by argument2', (done) ->
		dexdis.incrby 'incrby', 10, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 10
			dexdis.get 'incrby', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 10
				do done
	it 'should increment the value of the key by argument2', (done) ->
		dexdis.set 'incrby', 32, (err) ->
			expect(err).to.be.null
			dexdis.incrby 'incrby', 10, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				dexdis.get 'incrby', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 42
					do done
