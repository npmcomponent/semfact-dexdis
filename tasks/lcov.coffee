
module.exports = (grunt) ->
	
	grunt.registerMultiTask 'lcov', 'Create lcov file from js-coverage information', ->
		opts = @options {}
		for info in @files
			coverage = grunt.file.readJSON info.src
			for file, data of coverage
				str = "SF:#{file}\n"
				for num, line in data
					if num?
						str += "DA:#{line},#{num}\n"
			str += 'end_of_record\n'
			grunt.file.write info.dest, str
