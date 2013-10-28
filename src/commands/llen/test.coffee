describe 'LLEN', ->
	it 'should return 0 if the list is empty or does not exist', (done) ->
		dexdis.llen 'llen', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
	it 'should return the length of a list', (done) ->
		dexdis.lpush 'llen', 'foo', 'bar', (err, res) ->
			expect(err).to.be.null
			dexdis.llen 'llen', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 2
				do done
