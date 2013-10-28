describe 'LPOP', ->
	it 'should return null if the key does not exist', (done) ->
		dexdis.lpop 'lpop', (err, res) ->
			expect(err).to.be.null
			expect(res).to.be.null
			do done
	it 'should return the value at the index of the list and remove it', (done) ->
		dexdis.lpush 'lpop', 'test', (err) ->
			expect(err).to.be.null
			dexdis.lpop 'lpop', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				dexdis.lindex 'lpop', 0, (err, res) ->
					expect(err).to.be.null
					expect(res).to.be.null
					do done
