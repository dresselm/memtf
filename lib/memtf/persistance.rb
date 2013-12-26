require 'fileutils'
require 'multi_json'

# Encapsulates the logic and mechanism for saving
# and loading raw memory data.
class Memtf::Persistance
  # The directory where raw data is stored
  OUTPUT_DIR = "tmp/memtf"

  class << self
    # Serialize group data to the filesystem.
    #
    # @param [String] name
    # @param [String] group
    # @param [Object] payload
    def save(name, group, payload)
      group_directory = group_dir(group)
      FileUtils.mkdir_p("#{group_directory}")

      save_file = "#{group_directory}/#{name}.json"
      File.open(save_file, 'w+') do |f|
        f.puts ::MultiJson.encode(payload)
      end
    end

    # De-serialize group data from the filesystem.
    #
    # @param [String] name
    # @param [String] group
    # @return [Object]
    def load(name, group)
      load_file = "#{group_dir(group)}/#{name}.json"
      ::MultiJson.decode File.read(load_file)
    end

    private

    # @param [String] group
    # @return [String] the group dir
    def group_dir(group)
      "#{OUTPUT_DIR}/#{group}"
    end
  end
end