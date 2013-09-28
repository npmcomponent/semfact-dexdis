describe 'STRLEN', ->
	it 'should return the length of the string value of the key', (done) ->
		dexdis.set 'str', 'test', (err) ->
			expect(err).to.be.null
			dexdis.strlen 'str', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 4
				do done
	it 'should return 0 if the key does not exist', (done) ->
		dexdis.strlen 'str', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
