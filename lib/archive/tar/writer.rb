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
