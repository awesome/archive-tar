require File.join(File.dirname(__FILE__), 'test_helper')

class MainTest < Test::Unit::TestCase
	def teardown
		clean TMP_ROOT
	end

	def test_creation_with_explicit_files
		Archive::Tar.create( tmp('files.tar'),
		  [ 'test/work/files/literature/chaucer/clerk.txt' ] )
		assert File.exists?(tmp('files.tar')), "Unable to create files.tar"

		Archive::Tar.create( tmp('files.tgz'),
		  [ 'test/work/files/literature/chaucer/clerk.txt' ],
		  :compression => :gzip )
		assert File.exists?(tmp('files.tgz')), "Unable to create files.tgz"
	end

	def test_creation_with_directories
		Archive::Tar.create( tmp('dir.tar'),
		  [ 'test/work/files/literature/chaucer' ] )
		assert File.exists?(tmp('dir.tar')), "Unable to create dir.tar"

		Archive::Tar.create( tmp('dir.tgz'),
		  [ 'test/work/files/literature/chaucer/clerk.txt' ],
		  :compression => :gzip )
		assert File.exists?(tmp('dir.tgz')), "Unable to create dir.tgz"
	end

	def test_extraction_of_unix_archives
		clean EXTRACT_ROOT
		Archive::Tar.extract( archive('unix.tar'), EXTRACT_ROOT )
		assert_extracted(EXTRACT_ROOT)

		clean EXTRACT_ROOT
		Archive::Tar.extract( archive('unix.tgz'), EXTRACT_ROOT, :compression => :gzip )
		assert_extracted(EXTRACT_ROOT)
	end
end
