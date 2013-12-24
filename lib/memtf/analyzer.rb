require 'objspace'

class Memtf::Analyzer

  attr_reader :threshold, :filter

  DEFAULT_THRESHOLD = 0.005
  MB = 1024.0**2

  # @param [Hash] options
  def self.analyze(options={})
    new(options).analyze
  end

  # @param [String] group
  # @return [Hash]
  def self.analyze_group(group)
    start_analysis = Memtf::Persistance.load(Memtf::START,  group)
    end_analysis   = Memtf::Persistance.load(Memtf::STOP,   group)

    comparison    = {}
    total_memsize = 0

    end_analysis.each do |clazz,end_stats|
      start_stats       = start_analysis[clazz]
      comparison[clazz] = {}

      end_stats.each do |stat_key, stat_values|
        start_val = start_stats.nil? ? 0 : start_stats[stat_key]
        end_val   = end_stats[stat_key]
        delta     = end_val - start_val
        comparison[clazz][stat_key] = delta

        # Perhaps just compare this
        total_memsize += delta if stat_key == 'size'
      end
    end

    # Determine the relative memory impact of each class
    comparison.keys.each do |klazz|
      stats           = comparison[klazz]
      stats['impact'] = stats['size'] / total_memsize
    end

    comparison
  end

  def initialize(options={})
    @filter    = options[:filter]
    @threshold = options.fetch(:threshold, DEFAULT_THRESHOLD)
  end

  # @return [Hash]
  def analyze
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
    calculator = lambda do |obj|
      clazz = obj.is_a?(Array) ? obj.first.class : obj.class
      if clazz.respond_to?(:name)
        class_name    = clazz.name
        class_stats   = (classes_stats[class_name] ||= [])

        obj_memsize   = ObjectSpace.memsize_of(obj)
        class_stats   << obj_memsize
        total_memsize += obj_memsize
      end
    end
    ObjectSpace.each_object(&calculator)

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