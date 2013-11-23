describe 'LDEL', ->
	it 'should return an empty array if the key does not exist', (done) ->
		dexdis.ldel 'ldel', 1, 1, (err, res) ->
			expect(err).to.be.null
			expect(res).to.eql []
			do done
	it 'should remove the list if the list would be empty', (done) ->
		dexdis.lpush 'ldel', 'test', (err) ->
			expect(err).to.be.null
			dexdis.ldel 'ldel', 0, -1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.eql ['test']
				dexdis.exists 'ldel', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 0
					do done
	it 'should return an array of the values in the list determined by the indexes and remove them', (done) ->
		dexdis.lpush 'ldel', 'baz', 'bar', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.ldel 'ldel', 1, 2, (err, res) ->
				expect(err).to.be.null
				expect(res).to.eql ['bar', 'baz']
				dexdis.llen 'ldel', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 1
					dexdis.lindex 'ldel', 1, (err, res) ->
						expect(err).to.be.null
						expect(res).to.be.null
						do done
	it 'should return an array of the values in the list determined by negative indexes and remove them', (done) ->
		dexdis.lpush 'ldel', 'baz', 'bar', 'foo', (err) ->
			expect(err).to.be.null
			dexdis.ldel 'ldel', -1, 1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.eql ['baz', 'bar']
				dexdis.llen 'ldel', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 1
					dexdis.lindex 'ldel', 1, (err, res) ->
						expect(err).to.be.null
						expect(res).to.be.null
						do done
