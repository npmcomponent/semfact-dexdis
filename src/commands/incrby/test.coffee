describe 'INCRBY', ->
	it 'should set the value of the key to the increment if the key does not exist', (done) ->
		dexdis.incrby 'incrby', 10, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 10
			dexdis.get 'incrby', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 10
				do done
	it 'should increment the value of the key by the given increment', (done) ->
		dexdis.set 'incrby', 32, (err) ->
			expect(err).to.be.null
			dexdis.incrby 'incrby', 10, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				dexdis.get 'incrby', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 42
					do done
