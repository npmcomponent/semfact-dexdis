describe 'DECRBY', ->
	it 'should set the value of the key to zero if the key does not exist and decrement it by argument2', (done) ->
		dexdis.decrby 'decrby', 10,(err, res) ->
			expect(err).to.be.null
			expect(res).to.equal -10
			dexdis.get 'decrby', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal -10
				do done
	it 'should decrement the value of the key by argument2', (done) ->
		dexdis.set 'decrby', 52, (err) ->
			expect(err).to.be.null
			dexdis.decrby 'decrby', 10,  (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				dexdis.get 'decrby', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 42
					do done
