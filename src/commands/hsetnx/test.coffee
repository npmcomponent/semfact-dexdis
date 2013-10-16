describe 'HSETNX', ->
	it 'should set the field if the key does not exist', (done) ->
		dexdis.hsetnx 'hsetnx', 'foo', 42, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.hget 'hsetnx', 'foo', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 42
				do done
	it 'should set the field if the key already exists', (done) ->
		dexdis.hsetnx 'hsetnx', 'foo', 42, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.hsetnx 'hsetnx', 'bar', 23, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 1
				dexdis.hget 'hsetnx', 'bar', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 23
					do done
	it 'should not set the field if the field already exists', (done) ->
		dexdis.hsetnx 'hsetnx', 'foo', 42, (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 1
			dexdis.hsetnx 'hsetnx', 'foo', 23, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 0
				dexdis.hget 'hsetnx', 'foo', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 42
					do done
