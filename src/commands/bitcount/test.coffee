describe 'BITCOUNT', ->
	it 'should return the number of bits set to 1 of the value stored at the key', (done) ->
		dexdis.set 'bits', 0xe5, (err, res) ->
			expect(err).to.be.null
			dexdis.bitcount 'bits', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 5
				do done
	it 'should return the number of bits set to 1 of the value stored at key determined by negative offsets', (done) ->
		dexdis.set 'bits', 0xe5ff00ff, (err, res) ->
			expect(err).to.be.null
			dexdis.bitcount 'bits', -1, -1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 5
				do done
	it 'should return the substring of a string stored at key determined by the offsets', (done) ->
		dexdis.set 'bits', 0xff00ffe5, (err, res) ->
			expect(err).to.be.null
			dexdis.bitcount 'bits', 0, 1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 5
				do done
	it 'should return 0 if the key does not exist', (done) ->
		dexdis.bitcount 'bits', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
