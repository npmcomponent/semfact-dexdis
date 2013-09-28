describe 'GET', ->
	it 'should get the value of the key', (done) ->
		dexdis.set 'get', 'test', (err) ->
			expect(err).to.be.null
			dexdis.get 'get', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				do done
	it 'should return null if the key does not exist', (done) ->
		dexdis.get 'get', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal null
			do done
		
