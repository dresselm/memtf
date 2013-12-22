require 'fileutils'
require 'multi_json'

class Memtf::Persistance
  OUTPUT_DIR = "tmp/memtf"

  class << self
    def save(name, group, payload)
      group_directory = group_dir(group)
      FileUtils.mkdir_p("#{group_directory}")

      save_file = "#{group_directory}/#{name}.json"
      File.open(save_file, 'w+') do |f|
        f.puts ::MultiJson.encode(payload)
      end
    end

    def load(name, group)
      load_file = "#{group_dir(group)}/#{name}.json"
      ::MultiJson.decode File.read(load_file)
    end

    private

    def group_dir(group)
      "#{OUTPUT_DIR}/#{group}"
    end
  end
end