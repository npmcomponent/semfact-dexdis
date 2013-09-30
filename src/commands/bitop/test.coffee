describe 'BITOP', ->
	it 'should do an AND operation with the values stored at the keys', (done) ->
		dexdis.set 'key1', 0x00ff00ff, (err, res) ->
			expect(err).to.be.null
			dexdis.set 'key2', 0x000000ff, (err, res) ->
				expect(err).to.be.null
				dexdis.bitop 'AND', 'res', 'key1', 'key2', (err, res) ->
					expect(err).to.be.null
					dexdis.get 'res', (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 0xff
						do done
	it 'should do an OR operation with the values stored at the keys', (done) ->
		dexdis.set 'key1', 0x00ff00ff, (err, res) ->
			expect(err).to.be.null
			dexdis.set 'key2', 0x0f00ff00, (err, res) ->
				expect(err).to.be.null
				dexdis.bitop 'OR', 'res', 'key1', 'key2', (err, res) ->
					expect(err).to.be.null
					dexdis.get 'res', (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 0x0fffffff
						do done
	it 'should do a XOR operation with the values stored at the keys', (done) ->
		dexdis.set 'key1', 0x00ff00ff, (err, res) ->
			expect(err).to.be.null
			dexdis.set 'key2', 0x00ff0000, (err, res) ->
				expect(err).to.be.null
				dexdis.bitop 'XOR', 'res', 'key1', 'key2', (err, res) ->
					expect(err).to.be.null
					dexdis.get 'res', (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 0x000000ff
						do done
	it 'should do an operation with the values stored at the keys with more than two keys', (done) ->
		dexdis.set 'key1', 0x00ff00ff, (err, res) ->
			expect(err).to.be.null
			dexdis.set 'key2', 0x000000ff, (err, res) ->
				expect(err).to.be.null
				dexdis.set 'key3', 0x0000000f, (err, res) ->
					expect(err).to.be.null
					dexdis.bitop 'AND', 'res', 'key1', 'key2', 'key3', (err, res) ->
						expect(err).to.be.null
						dexdis.get 'res', (err, res) ->
							expect(err).to.be.null
							expect(res).to.equal 0x0f
							do done
	it 'should do a NOT operation with the value stored at the key', (done) ->
		dexdis.set 'key', 0xff00ff00, (err, res) ->
			expect(err).to.be.null
			dexdis.bitop 'NOT', 'res', 'key', (err, res) ->
				expect(err).to.be.null
				dexdis.get 'res', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 0x00ff00ff
					do done
