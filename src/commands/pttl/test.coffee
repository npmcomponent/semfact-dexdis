describe 'PTTL', ->
	it 'should return the time to live in milliseconds', (done) ->
		dexdis.set 'pttl', 'test', (err) ->
			expect(err).to.be.null
			dexdis.pexpire 'pttl', 1500, (err) ->
				expect(err).to.be.null
				dexdis.pttl 'pttl', (err, ttl) ->
					expect(err).to.be.null
					expect(ttl).to.be.within 1000,1500
					do done
	it 'should return -1 if no ttl is set', (done) ->
		dexdis.set 'pttl', 'test', (err) ->
			expect(err).to.be.null
			dexdis.pttl 'pttl', (err, ttl) ->
				expect(err).to.be.null
				expect(ttl).to.equal -1
				do done
	it 'should return -2 if key does not exist', (done) ->
		dexdis.pttl 'pttl', (err, ttl) ->
			expect(err).to.be.null
			expect(ttl).to.equal -2
			do done
