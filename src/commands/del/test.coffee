describe 'DEL', ->
	it 'should delete keys if the they exist', (done) ->
		dexdis.set 'del1', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.set 'del2', 'test', (err, res) ->
				expect(err).to.be.null
				dexdis.del 'del1', 'del2',  (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					do done
	it 'should ignore keys that do not exist', (done) ->
		dexdis.set 'del1', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.set 'del2', 'test', (err, res) ->
				expect(err).to.be.null
				dexdis.del 'del0', 'del1', 'del2', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					do done
	it 'should do nothing if all keys do not exist', (done) ->
		dexdis.del 'foo', 'bar', (err, res) ->
			expect(err).to.be.null
			expect(res).to.equal 0
			do done
	it 'should delete keys if the last key does not exist', (done) ->
		dexdis.set 'del1', 'test', (err, res) ->
			expect(err).to.be.null
			dexdis.set 'del2', 'test', (err, res) ->
				expect(err).to.be.null
				dexdis.del 'del1', 'del2', 'del0', (err, res) ->
					expect(err).to.be.null
					expect(res).to.equal 2
					dexdis.get 'del1', (err, res) ->
						expect(err).to.be.null
						expect(res).to.be.null
						do done
