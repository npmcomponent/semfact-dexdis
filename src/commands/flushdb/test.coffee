describe 'FLUSHDB', ->
	it 'should delete all keys in the database', (done) ->
		dexdis.set 'flush', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.flushdb (err, res) ->
				expect(res).to.equal 'OK'
				dexdis.get 'flush', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal null
					do done
