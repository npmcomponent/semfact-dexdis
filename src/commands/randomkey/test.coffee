describe 'RANDOMKEY', ->
	it 'should return the key if there is only one', (done) ->
		dexdis.set 'random', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.randomkey (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'random'
				do done
	it 'should return null if there is no key', (done) ->
		dexdis.randomkey (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal null
			do done
	it 'should return a random key', (done) ->
		dexdis.set 'foo', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.set 'bar', 'test', (err, res) ->
				expect(err).to.be.null
				dexdis.randomkey (err, res) ->
					expect(err).to.be.null
					expect(res).to.satisfy (key) ->
						key is 'foo' or 'bar'
					do done
