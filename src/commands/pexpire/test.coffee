describe 'PEXPIRE', ->
	it 'should set the timeout to the key', (done) ->
		dexdis.set 'pexpire', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.pexpire 'pexpire', 1500, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				dexdis.pttl 'pexpire', (err, res) ->
					expect(err).to.be.null
					expect(res).to.be.within 1000, 1500
					do done
	it 'should return 0 if the key does not exist', (done) ->
			dexdis.pexpire 'pexpire', 1500, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				do done
