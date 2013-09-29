describe 'GETRANGE', ->
	it 'should return the substring of a string stored at key determined by the offsets', (done) ->
		dexdis.set 'string', 'Hello World', (err, res) ->
			expect(err).to.be.null
			dexdis.getrange 'string', 0, 5, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'Hello'
				do done
	it 'should return the substring of a string stored at key determined by negative offsets', (done) ->
		dexdis.set 'string', 'Hello World', (err, res) ->
			expect(err).to.be.null
			dexdis.getrange 'string', -5, -1, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'World'
				do done
	it 'should return the substring of a string stored at key determined by the offsets with an end longer than the string', (done) ->
		dexdis.set 'string', 'Hello World', (err, res) ->
			expect(err).to.be.null
			dexdis.getrange 'string', 0, 100, (err, res) ->
				expect(err).to.be.null
				expect(res).to.equal 'Hello World'
				do done
