include Helpers::ModuleHelper
include YARD::Gcloud::SideNav

def init
  sections :index
end

def methods_in_groups groups, methods
  methods = methods.select { |m| m.visibility == :public }
  methods = methods.reject { |m| m.tag :private }

  others = []
  if groups
    group_data = groups.dup
    methods.each {|m| groups_data |= [m.group] if m.group }
    group_data.each do |group|
      items = methods.select {|m| m.group == group }
      yield(group, items) unless items.empty?
    end
    others = methods.select {|m| !m.group || !group_data.include?(m.group) }
  else
    group_data = {}
    methods.each do |meth|
      if meth.group
        (group_data[meth.group] ||= []) << meth
      else
        others << meth
      end
    end
    group_data.each {|group, items| yield(group, items) unless items.empty? }
  end

  [:class, :instance].each do |scope|
    items = others.select {|m| m.scope == scope }
    yield("#{scope.to_s.capitalize} Methods", items) unless items.empty?
  end
end
