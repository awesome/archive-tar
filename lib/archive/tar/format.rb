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

class Archive::Tar::Format # :nodoc:
	DEC_TYPES = {
		'0'  => :file,
		"\0" => :file,
		'1'  => :link,
		'2'  => :symlink,
		'3'  => :character,
		'4'  => :block,
		'5'  => :directory,
		'6'  => :fifo,
		'7'  => :contiguous
	}

	ENC_TYPES = {
		:file       => '0',
		:link       => '1',
		:symlink    => '2',
		:character  => '3',
		:block      => '4',
		:directory  => '5',
		:fifo       => '6',
		:contiguous => '7'
	}


	class << self
		def next_block(io)
			block = ''
			loop do
				block = io.read(512)
				return block unless block == "\0" * 512
				return nil if io.eof?
			end
		end

		def unpack_header(block)
			h = block.unpack("Z100 Z8 Z8 Z8 Z12 Z12 A8 a Z100 Z6 Z2 Z32 Z32 Z8 Z8 Z155")
			{
				:path  => h.shift,
				:mode  => h.shift.oct,
				:uid   => h.shift.oct,
				:gid   => h.shift.oct,
				:size  => h.shift.oct,
				:mtime => Time.at(h.shift.oct),
				:cksum => h.shift.oct,
				:type  => DEC_TYPES[h.shift],
				:dest  => h.shift,
				:ustar => h.shift.strip == 'ustar',
				:uvers => h.shift.strip,
				:user  => h.shift,
				:group => h.shift,
				:major => h.shift.oct,
				:minor => h.shift.oct,
				:pre   => h.shift
			}
		end

		def pack_header(h)
			packed = [
				h[:path],
				"%07o"  % h[:mode],
				"%07o"  % h[:uid],
				"%07o"  % h[:gid],
				"%011o" % h[:size],
				"%011o" % h[:mtime].to_i,
				'',
				ENC_TYPES[h[:type]],
				h[:dest],
				h[:ustar] ? "ustar" : '',
				"00",
				h[:user],
				h[:group],
				"%07o" % h[:major],
				"%07o" % h[:minor],
				h[:pre]
			].pack("a100 a8 a8 a8 a12 a12 A8 a a100 a6 a2 a32 a32 a8 a8 a155 x12")
			packed[148, 7] = "%06o\0" % packed.unpack("C*").inject { |total, byte| total + byte }
			packed
		end

		def stat(path, inodes)
			lstat = File.lstat(path)
			dest = lstat.symlink? ? File.readlink(path) : inodes[lstat.ino]

			inodes[lstat.ino] ||= path

			size = lstat.size
			size = 0 if dest || !lstat.file?

			{
				:path  => path[0,1] == '/' ? path[1, path.size - 1] : path,
				:mode  => lstat.mode,
				:uid   => lstat.uid,
				:gid   => lstat.gid,
				:size  => size,
				:mtime => lstat.mtime.to_i,
				:type  => (lstat.file? && dest ? :link : lstat.tar_type),
				:dest  => dest.to_s,

				:ustar => true,
				:uvers => "00",
				:user  => Etc.getpwuid(lstat.uid).name,
				:group => Etc.getgrgid(lstat.gid).name,
				:major => lstat.dev_major.to_i,
				:minor => lstat.dev_minor.to_i,
				:pre   => '', # FIXME: implement
			}
		end
	end
end
