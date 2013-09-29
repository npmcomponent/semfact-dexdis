describe 'TYPE', ->
	it 'should return the type of the value stored at key', (done) ->
		dexdis.set 'type', {foo: 'bar'}, (err, res) ->
			expect(err).to.be.null
			dexdis.type 'type',  (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'simple'
				do done
