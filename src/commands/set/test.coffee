describe 'SET', ->
	it 'should set the value of the key to the argument', (done) ->
		dexdis.set 'set', 'test', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 'OK'
			dexdis.get 'set', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'test'
				do done
	it 'should set the value of the key to the argument even if the key already exists', (done) ->
		dexdis.set 'set', 'hello', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 'OK'
			dexdis.set 'set', 'test', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'OK'
				dexdis.get 'set', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'test'
					do done
