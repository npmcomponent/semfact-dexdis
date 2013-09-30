describe 'PSETEX', ->
	it 'should set the value of the key to the argument and its timeout', (done) ->
		dexdis.psetex 'psetex', 1500, 'test', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 'OK'
			dexdis.get 'psetex', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				dexdis.pttl 'psetex', (err, res) ->
					expect(err).to.be.null
					expect(res).to.be.within 1000, 1500
					do done
