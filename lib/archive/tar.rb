module Archive #:nodoc:
end

#
# == Extract Options
#
# * <tt>:permissions</tt> - If set to <tt>:preserve</tt>, then the Reader will
#   attempt to chown and chmod the extracted to files to match the mode, UID
#   and GID stored in the archive.  For every other value, UID and GID will be
#   taken from the executing user, and mode from that user's <tt>umask</tt>.
#
#   <b>Note:</b> on most operating systems (notably UNIX/Linux) the only user
#   with rights to change ownership of files and directory is the <tt>root</tt>
#   user.
#
# == Archive Options
#
# * <tt>:compression</tt> - If set to <tt>:gzip</tt>, then the Reader will
#   decompress the tar file on-the-fly (without any temp files) as it extracts
#   the tarred files.  For every other value, no decompression is done.
#   <i>Bzip2 compression is not yet supported</i>.
#
module Archive::Tar
	# :stopdoc:
	UNIX_VERBOSE = Proc.new { |s, _|
		if (s[:type] == :link)
			print 'h'
		else
			print '-'
		end
		[ (s[:mode] & 0700) >> 6, (s[:mode] & 0070) >> 3, (s[:mode] & 0007) ].each do |p|
			print p & 04 == 04 ? 'r' : '-'
			print p & 02 == 02 ? 'w' : '-'
			print p & 01 == 01 ? 'x' : '-'
		end
		print ' '
		print "#{s[:user]}/#{s[:group]}".ljust(16, ' ')
		print s[:size].to_s.rjust(8,' ')
		print ' '
		print Time.at(s[:mtime]).strftime("%Y-%m-%d %H:%M")
		print ' '
		print s[:path]
		if (s[:type] == :link)
			print ' link to '
			print s[:dest]
		end
		puts
	}
	# :startdoc:

	class << self
		# 
		# Extract a tar archive (+source_file+) into +dest_dir+.  +source_file+
		# must exist and the executing user must be able to read it.
		# Additionally, +dest_dir+ must exist, and the executing user must be
		# allowed to write to it.
		#
		# +options+ is an optional hash of parameters that influence the nature
		# of the extraction.  See Extract Options and Archive Options (above)
		# for information on possible values.
		#
		def extract(source_file, dest_dir, options = {})
			Reader.new(source_file, options).extract(dest_dir, options)
		end

		#
		# Creates a new tar archive in +dest_file+.  A list of paths to store in the
		# archive should be passed next.  The last argument can optionally be a hash
		# of options that will dictate how the archive is created (see Archive
		# Options, above).
		#
		# Example:
		#
		#   Archive::Tar.create(
		#     '~/ruby.tar.gz',       # Where to put the archive
		#     Dir["~/code/**/*.rb"], # What to tar up
		#     :compression => :gzip, # Gzip it, to save some space
		#   )
		#
		def create(dest_file, filenames = [], options = {})
			Writer.new(filenames).write(dest_file, options)
		end

		#
		# Cycle through the entries in a tar archive, and pass each entry to a
		# caller-supplied block.  This is the easiest way to emulate the <tt>-t</tt>
		# option to the canonical UNIX <tt>tar</tt> utility.
		#
		# Each time +block+ is invoked, it will be passed a symbolic-key hash of the
		# header information (owner, size, last modification time, etc.) and the
		# contents of the file.  For all file types except a normal file, contents 
		# will be nil.
		#
		# To list the path names of all entries in an archive:
		#
		#   Archive::Tar.traverse('ruby.tar.gz', :compression => :gzip) do |header, contents|
		#     puts header[:path]
		#   end
		#
		def traverse(source_file, options = {}, &block) # :yields: header, contents
			block ||= UNIX_VERBOSE
			Reader.new(source_file, options).each(&block)
		end
	end
end

require 'archive/tar/format'
require 'archive/tar/reader'
require 'archive/tar/writer'
require 'archive/tar/stat'
