require File.join(File.dirname(__FILE__), 'test_helper')
require 'stringio'
require 'pp'

class FormatTest < Test::Unit::TestCase
	def test_nil_block_skippage
		io = StringIO.new( ("\0" * 512) + "test" )
		assert_equal "test", Archive::Tar::Format.next_block(io)

		io = StringIO.new( ("\0" * 512 * 6) + "test" )
		assert_equal "test", Archive::Tar::Format.next_block(io)
	end

	def test_block_size
		io = StringIO.new("A" * 600)
		assert_equal "A" * 512, Archive::Tar::Format.next_block(io)
	end

	def test_header_packing
		header = {
			:path  => 'testing/path/file.pdf',
			:mode  => 0100640,
			:uid   => 01234,
			:gid   => 04321,
			:size  => 0233455,
			:mtime => Time.local(1991, 8, 26, 1, 12, 00),
			:type  => :file,
			:dest  => '(dest)', # Not strictly in-spec, but helpful for testing
			:ustar => true,
			:uvers => '00',
			:user  => 'jrhunt',
			:group => 'users',
			:major => 1,
			:minor => 2,
			:pre   => '(prefix)' # Not strictly in-spec, but helpful for testing
		}
	 	binary = Archive::Tar::Format.pack_header(header)

		# Kind of brittle, but it's all I've got...
		expected = "testing/path/file.pdf" + "\0" * (100 - 21)
		expected += "0100640\0" + "0001234\0" + "0004321\0"
		expected += "00000233455\0"
		expected += "05056115660\0" # Time.local(1991, 8, 26, 1, 12, 00)
		expected += "        "
		expected += "0"
		expected += '(dest)' + "\0" * (100 - 6)
		expected += "ustar\0" + "00"
		expected += "jrhunt" + "\0" * (32 - 6)
		expected += "users" + "\0" * (32 - 5)
		expected += "0000001\0" + "0000002\0"
		expected += "(prefix)" + "\0" * (155 - 8)
		expected += "\0" * 12
		assert_equal 512, expected.size

		cksum = 0
		expected.each_byte { |b| cksum += b }
		expected[148,8] = cksum.to_s(8).rjust(6,'0') + "\0 "


		assert_equal expected, binary
	end

	def test_header_unpacking
		# REMEMBER: This is a GNU Tar archive
		binary = IO.read archive('header.tar'), 512
		header = Archive::Tar::Format.unpack_header(binary)

		assert_equal 'literature/chaucer/wife-of-bath.txt', header[:path]
		assert_equal 0644, header[:mode]

		assert_equal 1000, header[:uid] # jrhunt on finwe
		assert_equal 'jrhunt', header[:user]

		assert_equal 100,  header[:gid] # users on finwe
		assert_equal 'users', header[:group]

		assert_equal 69577,  header[:size]
		assert_equal Time.local(2008, 8, 8, 10, 11, 18), header[:mtime]
		assert_equal :file, header[:type]
		assert_equal '', header[:dest]

		assert_equal true, header[:ustar]
		assert_equal '', header[:uvers] # GNU doesn't follow POSIX properly.
	end
end
