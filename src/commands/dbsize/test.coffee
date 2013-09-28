describe 'DBSIZE', ->
	it 'should return the number of keys in the database', (done) ->
		dexdis.set 'a', 1, (err) ->
			expect(err).to.be.null
			dexdis.set 'b', 2, (err) ->
				expect(err).to.be.null
				dexdis.dbsize (err, size) ->
					expect(err).to.be.null
					expect(size).to.equal 2
					do done
