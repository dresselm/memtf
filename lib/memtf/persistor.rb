class Memtf::Persistor
	OUTPUT_DIR = "tmp/memtf"

	def self.persist(name, group, payload)
		FileUtils.mkdir_p("#{OUTPUT_DIR}/#{group}")
    save_file = "#{OUTPUT_DIR}/#{group}/#{name}.json"

    File.open(save_file, 'w+') do |f|
      f.puts ::MultiJson.encode(payload)
    end
	end

	def self.load(name, group)
		::MultiJson.decode File.read("#{OUTPUT_DIR}/#{group}/#{name}.json")
	end
end