describe 'GETBIT', ->
	it 'should return the bit value at the offset in the value stored at the key', (done) ->
		dexdis.set 'bits', 5, (err, res) ->
			expect(err).to.be.null
			dexdis.getbit 'bits', 2, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				do done
	it 'should return 0 if the offset is higher than the length of the value stored at the key', (done) ->
		dexdis.set 'bits', 5, (err, res) ->
			expect(err).to.be.null
			dexdis.getbit 'bits', 100, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				do done
	it 'should return 0 if the key does not exist', (done) ->
		dexdis.getbit 'bits', 2, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
