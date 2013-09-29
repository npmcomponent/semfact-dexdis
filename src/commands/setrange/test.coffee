describe 'SETRANGE', ->
	it 'should overwrite the string stored at key starting at offset', (done) ->
		dexdis.set 'setrange', 'Hello World', (err, res) ->
			expect(err).to.be.null
			dexdis.setrange 'setrange', 6, 'Universe', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 14
				dexdis.get 'setrange', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'Hello Universe'
					do done
	it 'should overwrite the string stored at key starting at offset with an offset longer than the string', (done) ->
		dexdis.set 'setrange', 'Hello World', (err, res) ->
			expect(err).to.be.null
			dexdis.setrange 'setrange', 20, ' and Universe', (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 24
				dexdis.get 'setrange', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 'Hello World and Universe'
					do done
