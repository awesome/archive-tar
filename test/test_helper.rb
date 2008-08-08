require 'test/unit'
require 'fileutils'

$:.unshift( File.dirname(__FILE__) + '/../lib')
require 'archive/tar'

ROOT = File.join(File.dirname(__FILE__), 'work')
TMP_ROOT     = File.join(ROOT, 'tmp')
EXTRACT_ROOT = File.join(ROOT, 'extract')
ARCHIVE_ROOT = File.join(ROOT, 'archives')

class Test::Unit::TestCase
	# Customizations here
	
	def tmp(path)
		File.join(TMP_ROOT, path)
	end

	def archive(path)
		File.join(ARCHIVE_ROOT, path)
	end

	def clean(dir)
		FileUtils.rm_rf dir
		FileUtils.mkdir_p dir
	end

	def assert_extracted(path)
		assert File.exists?( File.join(path, 'literature', 'chaucer', 'clerk.txt') )
		assert File.exists?( File.join(path, 'literature', 'chaucer', 'wife-of-bath.txt') )
	end
end
