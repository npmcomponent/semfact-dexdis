describe 'PEXPIREAT', ->
	it 'should set the timeout to the key', (done) ->
		dexdis.set 'pexpireat', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.pexpireat 'pexpireat', Date.now()+1500, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				dexdis.pttl 'pexpireat', (err, res) ->
					expect(err).to.be.null
					expect(res).to.be.within 1000, 1500
					do done
	it 'should return 0 if the key does not exist', (done) ->
			dexdis.pexpireat 'pexpireat', Date.now(), (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				do done
