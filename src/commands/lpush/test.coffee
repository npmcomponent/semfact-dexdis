describe 'LPUSH', ->
	it 'should push a value at first position in a list', (done) ->
		dexdis.lpush 'lpush', 'foo', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.lindex 'lpush', 0, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'foo'
				dexdis.lpush 'lpush', 'bar', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					dexdis.lindex 'lpush', 0, (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 'bar'
						dexdis.lindex 'lpush', 1, (err, res) ->
							expect(err).to.be.null
							expect(res).to.equal 'foo'
							do done
	it 'should push multiple values in a list', (done) ->
		dexdis.lpush 'lpush', 'foo', 'bar', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 2
			dexdis.lindex 'lpush', 0, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'bar'
				dexdis.lindex 'lpush', 1, (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'foo'
					do done
