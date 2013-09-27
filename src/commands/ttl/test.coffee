describe 'TTL', ->
	it 'should return the time to live in seconds', (done) ->
		dexdis.set 'ttl', 'test', (err) ->
			expect(err).to.be.null
			dexdis.expire 'ttl', 60, (err) ->
				expect(err).to.be.null
				dexdis.ttl 'ttl', (err, ttl) ->
					expect(err).to.be.null
					expect(ttl).to.equal 60
					do done
	it 'should return -1 if no ttl is set', (done) ->
		dexdis.set 'ttl', 'test', (err) ->
			expect(err).to.be.null
			dexdis.ttl 'ttl', (err, ttl) ->
				expect(err).to.be.null
				expect(ttl).to.equal -1
				do done
	it 'should return -2 if key does not exist', (done) ->
		dexdis.ttl 'ttl', (err, ttl) ->
			expect(err).to.be.null
			expect(ttl).to.equal -2
			do done
