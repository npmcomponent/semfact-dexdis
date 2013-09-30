describe 'SETBIT', ->
	it 'should set the bit value at the offset in the value stored at the key', (done) ->
		dexdis.set 'bits', 5, (err, res) ->
			expect(err).to.be.null
			dexdis.setbit 'bits', 1, 1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				dexdis.bitcount 'bits', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 3
					do done
	it 'should set the bit value even if the offset is higher than the length of the value stored at the key', (done) ->
		dexdis.set 'bits', 5, (err, res) ->
			expect(err).to.be.null
			dexdis.setbit 'bits', 30, 1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				dexdis.bitcount 'bits', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 3
					do done
	it 'should create a new value if the key does not exist', (done) ->
		dexdis.setbit 'bits', 2, 1, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			dexdis.get 'bits', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 4
				do done
