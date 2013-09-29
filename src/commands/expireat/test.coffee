describe 'EXPIREAT', ->
	it 'should set the timeout to the key', (done) ->
		dexdis.set 'expireat', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.expireat 'expireat', Date.now()/1000+10, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				dexdis.ttl 'expireat', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 10
					do done
	it 'should return 0 if the key does not exist', (done) ->
			dexdis.expireat 'expireat', Date.now(), (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				do done
