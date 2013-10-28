describe 'RPOP', ->
	it 'should return null if the key does not exist', (done) ->
		dexdis.rpop 'rpop', (err, res) ->
			expect(err).to.be.null
			expect(res).to.be.null
			do done
	it 'should return the value of the last element in the list and remove it', (done) ->
		dexdis.lpush 'rpop', 'test', (err) ->
			expect(err).to.be.null
			dexdis.rpop 'rpop', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				dexdis.lindex 'rpop', 0, (err, res) ->
					expect(err).to.be.null
					expect(res).to.be.null
					do done
