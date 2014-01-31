# Encapsulates logic that measures the memory footprint of all
# objects at a given point in time and compares the memory footprints
# of two points in time.
class Memtf::Analyzer

  attr_reader :threshold, :filter, :memory_tracker

  # The threshold of total memory consumption required
  # to be included in the output
  DEFAULT_THRESHOLD = 0.01
  # Represents 1 million bytes
  MB = 1024.0**2
  #
  EXCLUDED_CLASSES = [RubyVM::InstructionSequence]

  # Determine the memory footprint of each class and filter out classes
  # that do not meet the configured threshold.
  #
  # @param [Hash] options
  def self.analyze(options={})
    new(options).analyze
  end

  # Compare the memory footprints for the start and end memory snapshots
  # within the same snapshot group.
  #
  # @param [String] group
  # @return [Hash]
  def self.analyze_group(group)
    end_analysis  = Memtf::Persistance.load(Memtf::STOP,group)
    total_memsize = end_analysis.inject(0) do |sum, (clazz, end_stats)|
      sum += end_stats['size']
    end

    # Determine the relative memory impact of each class
    end_analysis.each do |clazz, end_stats|
      end_stats['impact'] = (end_stats['size']*1.0) / total_memsize
    end

    end_analysis
  end

  def initialize(options={})
    @filter         = options[:filter]
    @threshold      = options.fetch(:threshold, DEFAULT_THRESHOLD)
    @memory_tracker = options.fetch(:memory_tracker, Memtf::Analyzer::Memory)
  end

  # Determine the memory footprint of each class and filter out classes
  # that do not meet the configured threshold.
  #
  # @return [Hash]
  def analyze
    # Signal a new GC to attempt to clear out non-leaked memory
    # TODO investigate ObjectSpace.garbage_collect
    GC.start

    classes_stats = {}
    # TODO investigate ObjectSpace.count_objects_size[:TOTAL]
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
    memory_tracker.iterate do |obj|
      if obj.respond_to?(:class) && (clazz = obj.class).respond_to?(:name)
        unless EXCLUDED_CLASSES.include?(clazz)
          class_name    = clazz.name
          class_stats   = (classes_stats[class_name] ||= [])

          obj_memsize   = memory_tracker.size_of(obj)
          class_stats   << obj_memsize

          # Note: could also use ObjectSpace.memsize_of_all(clazz)
          total_memsize += obj_memsize
        end
      end
    end

    sorted_mem_hogs = identify_hogs(classes_stats, threshold * total_memsize)
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
  def identify_hogs(memory_by_class, mem_threshold)
    hogs, others = memory_by_class.partition do |k,v|
      v.sum > mem_threshold
    end

    hogs << ['Others*', Hash[others].values.flatten]
    Hash[hogs.sort_by {|k,v| -v.sum }]
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
        size:  size
      }
    end
    smh_hash
  end

end

require 'memtf/analyzer/memory'
