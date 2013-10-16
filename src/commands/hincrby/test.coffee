describe 'HINCRBY', ->
	it 'should set the value of the field to the increment if the field does not exist', (done) ->
		dexdis.hset 'hincrby', 'a', 42, (err) ->
			expect(err).to.be.null
			dexdis.hincrby 'hincrby', 'b', 10, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 10
				dexdis.hget 'hincrby', 'b', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 10
					do done
	it 'should increment the value of the field by the given increment', (done) ->
		dexdis.hset 'hincrby', 'a', 32, (err) ->
			expect(err).to.be.null
			dexdis.hincrby 'hincrby', 'a', 10, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				dexdis.hget 'hincrby', 'a', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 42
					do done
