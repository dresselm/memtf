class Memtf::Analyzer
	def self.analyze(options={})
		new(options).analyze
	end

	def self.analyze_group(group)
		start_analysis = Memtf::Persistor.load(Memtf::START_STAGE, group)
		end_analysis   = Memtf::Persistor.load(Memtf::FINISH_STAGE, group)

		comparison = {}

		end_analysis.each do |k,v|
      if v.is_a?(Hash)
        comparison[k] = {}
        next if start_analysis[k].nil?

        v.each do |key, value|
          comparison[k][key] = (v[key] - start_analysis[k][key])
        end
      else
        comparison[k] = (v - start_analysis[k.to_sym])
      end
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
	    size  = v.sum / (1024.0**2)

	    smh_hash[k] = {
	      count: count,
	      size: size
	    }
	  end; nil

	  smh_hash
	end
end