#-- license
#
# This file is part of the Ruby Archive::Tar Project
#
#  Copyright (c) 2008, James Hunt <filefrog@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#++ license

require 'zlib'
require 'fileutils'

class Archive::Tar::Reader
	def initialize(source, options = {})
		@source = source

		@options = {
			:compression => :none
		}.merge(options)
	end

	def each(full = false, &block)
		case @source
			when IO: parse(@source, full); @source.rewind
			else     File.open(@source, 'r') { |f| parse(f, full) }
		end

		@index.each { |path| yield *(@records[path]) }
	end

	def extract(dest, options = {})
		options = {
			:permissions => nil
		}.merge(options)

		raise "No such directory: #{dest}" unless File.directory?(dest)

		each(true) do |header, body|
			path = File.join(dest, header[:path])
			FileUtils.mkdir_p( File.dirname(path) )

			case header[:type]
				when :file:       File.open(path, 'w') { |fio| fio.write(body) }
				when :directory:  FileUtils.mkdir(path)
				when :link:       File.link( File.join(dest, header[:dest]), path )
				when :symlink:    File.symlink( header[:dest], path )
			end

			if options[:permissions] == :preserve && !File.symlink?(path)
				File.chmod header[:mode], path
				File.chown header[:uid].to_i, header[:gid].to_i, path
			end
		end
	end

	def parse(io, full = false)
		@index = []
		@records = {}

		io = Zlib::GzipReader.new(io) if @options[:compression] == :gzip

		until io.eof?
			hblock = Archive::Tar::Format.next_block(io)
			break unless hblock

			header = Archive::Tar::Format.unpack_header(hblock)
			path = header[:path]
			size = header[:size]

			@index << path
			@records[path] = [ header, io.read(size % 512 == 0 ? size : size + (512 - size % 512)) ]
			@records[path][1] = nil unless full
		end
	end
	private :parse
end
