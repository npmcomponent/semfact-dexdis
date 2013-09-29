describe 'SETNX', ->
	it 'should set the value of the key to the argument if the key does not exist', (done) ->
		dexdis.setnx 'setnx', 'foo', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.get 'setnx', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'foo'
				do done
	it 'should not set the value of the key to the argument if the key already exists', (done) ->
		dexdis.setnx 'setnx', 'foo', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.setnx 'setnx', 'bar', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				dexdis.get 'setnx', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'foo'
					do done
