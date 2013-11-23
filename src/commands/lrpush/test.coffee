describe 'LRPUSH', ->
	it 'should push a value to the last position in a list', (done) ->
		dexdis.lrpush 'lrpush', 'foo', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.lindex 'lrpush', 0, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'foo'
				dexdis.lrpush 'lrpush', 'bar', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					dexdis.lindex 'lrpush', 0, (err, res) ->
						expect(err).to.be.null
						expect(res).to.equal 'foo'
						dexdis.lindex 'lrpush', 1, (err, res) ->
							expect(err).to.be.null
							expect(res).to.equal 'bar'
							do done
	it 'should push multiple values in a list', (done) ->
		dexdis.lrpush 'lrpush', 'foo', 'bar', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 2
			dexdis.lindex 'lrpush', 0, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'foo'
				dexdis.lindex 'lrpush', 1, (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'bar'
					do done
