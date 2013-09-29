describe 'SETEX', ->
	it 'should set the value of the key to the argument and its timeout', (done) ->
		dexdis.setex 'setex', 10, 'test', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 'OK'
			dexdis.get 'setex', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				dexdis.ttl 'setex', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 10
					do done
