describe 'GETSET', ->
	it 'should set the key to the value and return the old value of the key', (done) ->
		dexdis.set 'getset', 'foo', (err, res) ->
			expect(err).to.be.null
			dexdis.getset 'getset', 'bar', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'foo'
				dexdis.get 'getset', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'bar'
					do done
