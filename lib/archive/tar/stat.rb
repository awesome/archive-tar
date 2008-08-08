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
