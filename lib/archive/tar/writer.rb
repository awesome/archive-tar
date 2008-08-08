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

require 'etc'
require 'zlib'

class Archive::Tar::Writer
	def initialize(filenames)
		@inodes = {}
		@records = {}
		@index = []
		filenames.each { |path| self << path }
	end

	def <<(filename)
		@index << filename
		@records[filename] = Archive::Tar::Format.stat(filename, @inodes)
		if File.directory?(filename)
			Dir.open(filename) do |dh|
				dh.entries.each do |file|
					self << File.join(filename, file) unless [".",".."].include? file
				end
			end
		end
	end

	def write(dest, options = {})
		if dest.is_a? IO
			write_to(dest, options)
		else
			File.open(dest, 'w') { |io| write_to(io, options) }
		end
	end

	def write_to(io, options = {})
		options = {
			:compression => :none
		}.merge(options)

		io = Zlib::GzipWriter.new(io) if options[:compression] == :gzip
		
		@index.each do |path|
			stat = @records[path]
			io.write Archive::Tar::Format.pack_header(stat)

			File.open(path, 'r') do |fio|
				io.write [fio.read(512)].pack("Z512") until fio.eof?
			end if stat[:dest].empty?
		end
		io.write("\0" * 1024)
		io.close
	end
	private :write_to
end
