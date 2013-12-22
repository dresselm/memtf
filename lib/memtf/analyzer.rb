require 'objspace'

class Memtf::Analyzer
  MB = 1024.0**2

  def self.analyze(options={})
    new(options).analyze
  end

  def self.analyze_group(group)
    start_analysis = Memtf::Persistance.load(Memtf::START_STAGE, group)
    end_analysis   = Memtf::Persistance.load(Memtf::FINISH_STAGE, group)

    comparison = {}
    total_memsize = 0

    end_analysis.each do |clazz,end_stats|
      start_stats = start_analysis[clazz]
      comparison[clazz] = {}

      end_stats.each do |stat_key, stat_values|
        start_val = start_stats.nil? ? 0 : start_stats[stat_key]
        end_val = end_stats[stat_key]
        delta   = end_val - start_val
        total_memsize += delta if stat_key == 'size'
        comparison[clazz][stat_key] = delta
      end
    end

    # Determine relative impact of each class
    comparison.keys.each do |klazz|
      stats = comparison[klazz]
      stats['impact'] = stats['size'] / total_memsize
    end

    comparison
  end

  def initialize(options={})
    @class_or_module_filter = options[:class_or_module_filter]
    @threshold = options.fetch(:threshold, 0.005)
  end

  def analyze
    GC.start

    class_stats   = {}
    total_memsize = 0

    obj_space_routine = lambda do |obj|
      if (clazz = obj.class).respond_to?(:name)
        class_name = clazz.name
        class_stat = (class_stats[class_name] ||= [])
        obj_memsize = ObjectSpace.memsize_of(obj)
        class_stat << obj_memsize
        total_memsize += obj_memsize
      end
    end

    if @class_or_module_filter.nil?
      ObjectSpace.each_object(&obj_space_routine)
    else
      ObjectSpace.each_object(@class_or_module_filter,&obj_space_routine)
    end

    threshold = @threshold * total_memsize
    mem_hogs = class_stats.select do |k,v|
      v.sum >= threshold
    end
    sorted_mem_hogs = Hash[mem_hogs.sort_by {|k,v| -v.sum }]

    smh_hash = {}
    sorted_mem_hogs.each do |k,v|
      count = v.size
      size  = v.sum / MB

      smh_hash[k] = {
        count: count,
        size: size
      }
    end; nil

    smh_hash
  end
end