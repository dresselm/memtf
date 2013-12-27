require 'objspace'

# Encapsulates logic that measures the memory footprint of all
# objects at a given point in time and compares the memory footprints
# of two points in time.
class Memtf::Analyzer

  attr_reader :threshold, :filter

  # The threshold of total memory consumption required
  # to be included in the output
  DEFAULT_THRESHOLD = 0.005
  # Represents 1 million bytes
  MB = 1024.0**2

  # Determine the memory footprint of each class and filter out classes
  # that do not meet the configured threshold.
  #
  # @param [Hash] options
  def self.analyze(options={})
    new_anal = new(options)
    # require 'pry'
    # binding.pry
    new_anal.analyze
  end

  # Compare the memory footprints for the start and end memory snapshots
  # within the same snapshot group.
  #
  # @param [String] group
  # @return [Hash]
  def self.analyze_group(group)
    start_analysis = Memtf::Persistance.load(Memtf::START, group)
    end_analysis   = Memtf::Persistance.load(Memtf::STOP,  group)

    comparison    = {}
    total_memsize = 0

    end_analysis.each do |clazz,end_stats|
      start_stats       = start_analysis[clazz]
      comparison[clazz] = {}

      end_stats.each do |stat_key, stat_values|
        start_val = start_stats.nil? ? 0 : start_stats[stat_key]
        end_val   = end_stats[stat_key]
        delta     = end_val - start_val

        comparison[clazz][stat_key]            = end_val
        comparison[clazz]["#{stat_key}_delta"] = delta

        total_memsize += end_val if stat_key == 'size'
      end
    end

    # Determine the relative memory impact of each class
    comparison.keys.each do |klazz|
      stats           = comparison[klazz]
      stats['impact'] = (stats['size']*1.0) / total_memsize
    end

    comparison
  end

  def initialize(options={})
    @filter    = options[:filter]
    @threshold = options.fetch(:threshold, DEFAULT_THRESHOLD)
  end

  # Determine the memory footprint of each class and filter out classes
  # that do not meet the configured threshold.
  #
  # @return [Hash]
  def analyze
    # Signal a new GC to attempt to clear out non-leaked memory
    GC.start

    classes_stats = {}
    total_memsize = 0

    # Track the memory footprint of each class
    # and calculate the cumulative footprint.
    #
    # Output:
    #
    #   {
    #     'Hash'   => [10, 15],
    #     'Fixnum' => [1],
    #     'Array'  => [20, 30, 40],
    #     'String' => [2,1]
    #   }
    #
    ObjectSpace.each_object do |obj|
      if (clazz = obj.class).respond_to?(:name)
        class_name    = clazz.name
        class_stats   = (classes_stats[class_name] ||= [])

        obj_memsize   = ObjectSpace.memsize_of(obj)
        class_stats   << obj_memsize

        # Note: could also use ObjectSpace.memsize_of_all(clazz)
        total_memsize += obj_memsize
      end
    end

    sorted_mem_hogs = identify_hogs(classes_stats, total_memsize)
    translate_hogs(sorted_mem_hogs)
  end

  private

  # Identify the most meaningful memory hogs, rollup the non-meaningful
  # classes into a single slot called 'Other*' and sort the results.
  #
  # Output:
  #
  #   {
  #     'Array'   => [20, 30, 40],
  #     'Hash'    => [10, 15],
  #     'Others*' => [1,2,1]
  #   }
  #
  # TODO Ensure threshold is easily configurable
  #
  # @param [Hash] memory_by_class
  # @param [Fixnum] total_memory_size
  # @return [Hash]
  def identify_hogs(memory_by_class, total_memory_size)
    mem_threshold = threshold * total_memory_size
    mem_hogs, others = {}, []
    memory_by_class.each_pair do |k,v|
      if v.sum >= mem_threshold
        mem_hogs[k] = v
      else
        others += v
      end
    end

    mem_hogs.merge!({'Others*' => others})
    Hash[mem_hogs.sort_by {|k,v| -v.sum }]
  end

  # Translate hogs into a suitable format
  #
  # Output:
  #
  #   {
  #     'Array'   => {:count => 3, :size => 90},
  #     'Hash'    => {:count => 2, :size => 25},
  #     'Others*' => {:count => 3, :size => 4}
  #   }
  #
  # @param [Hash] memory_hogs
  # @return [Hash]
  def translate_hogs(memory_hogs)
    smh_hash = {}
    memory_hogs.each do |k,v|
      count = v.size
      size  = v.sum / MB

      smh_hash[k] = {
        count: count,
        size: size
      }
    end
    smh_hash
  end

end
