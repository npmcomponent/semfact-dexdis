describe 'LRPOP', ->
	it 'should return null if the key does not exist', (done) ->
		dexdis.lrpop 'lrpop', (err, res) ->
			expect(err).to.be.null
			expect(res).to.be.null
			do done
	it 'should return the value of the last element in the list and remove it', (done) ->
		dexdis.lpush 'lrpop', 'test', (err) ->
			expect(err).to.be.null
			dexdis.lrpop 'lrpop', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				dexdis.lindex 'lrpop', 0, (err, res) ->
					expect(err).to.be.null
					expect(res).to.be.null
					do done
