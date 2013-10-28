describe 'RPUSH', ->
	it 'should push a value to the last position in a list', (done) ->
		dexdis.rpush 'rpush', 'foo', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.lindex 'rpush', 0, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'foo'
				dexdis.rpush 'rpush', 'bar', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					dexdis.lindex 'rpush', 0, (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 'foo'
						dexdis.lindex 'rpush', 1, (err, res) ->
							expect(err).to.be.null
							expect(res).to.equal 'bar'
							do done
	it 'should push multiple values in a list', (done) ->
		dexdis.rpush 'rpush', 'foo', 'bar', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 2
			dexdis.lindex 'rpush', 0, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'foo'
				dexdis.lindex 'rpush', 1, (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'bar'
					do done
