describe 'EXPIRE', ->
	it 'should set the timeout to the key', (done) ->
		dexdis.set 'expire', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.expire 'expire', 10, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				dexdis.ttl 'expire', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 10
					do done
	it 'should return 0 if the key does not exist', (done) ->
			dexdis.expire 'expire', 10, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				do done
