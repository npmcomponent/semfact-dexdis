describe 'APPEND', ->
	it 'should set the argument as value of the key if the key does not exist', (done) ->
		dexdis.append 'append', 'Hello', (err) ->
			expect(err).to.be.null
			dexdis.get 'append', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'Hello'
				do done
	it 'should append the argument to the end of the value of the key', (done) ->
		dexdis.append 'append', 'Hello', (err) ->
			expect(err).to.be.null
			dexdis.append 'append', ' world!', (err) ->
				expect(err).to.be.null
				dexdis.get 'append', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'Hello world!'
					do done
	it 'should return the length after the string is appended', (done) ->
		dexdis.append 'append', 'Hello', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 5
			dexdis.append 'append', ' world!', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 12
				do done
