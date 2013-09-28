describe 'DEL', ->
	it 'should delete arguments if the keys exist', (done) ->
		dexdis.set 'del1', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.set 'del2', 'test', (err, res) ->
				expect(err).to.be.null
				dexdis.del 'del1', 'del2',  (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					do done
	it 'should ignore arguments that does not exist', (done) ->
		dexdis.set 'del1', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.set 'del2', 'test', (err, res) ->
				expect(err).to.be.null
				dexdis.del 'del0', 'del1', 'del2', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					do done
