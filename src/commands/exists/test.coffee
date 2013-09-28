describe 'EXISTS', ->
	it 'should return 1 if the key exists', (done) ->
		dexdis.set 'exists', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.exists 'exists', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				do done
	it 'should return 0 if the key does not exist', (done) ->
		dexdis.exists 'not existant', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
