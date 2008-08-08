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

module Archive # :nodoc:
	module Tar
		module Stat # :nodoc:
			def tar_type
				case self.ftype
					when 'file':             :file
					when 'directory':        :directory
					when 'blockSpecial':     :block
					when 'characterSpecial': :character
					when 'link':             :symlink
				end
			end
		end
	end
end
File::Stat.send(:include, Archive::Tar::Stat)
