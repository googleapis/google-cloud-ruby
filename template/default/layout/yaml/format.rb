require "redcarpet"
require "yard"

class Formatter
  class Log
    # YARD records issues finding links via YARD::Logger#warn
    def warn str
      raise str
    end
  end

  include YARD::Templates::Helpers::BaseHelper
  include YARD::Templates::Helpers::HtmlHelper

  attr_accessor :object
  attr_accessor :options
  attr_accessor :serializer

  def initialize object, options
    @original_object = object
    @object = object
    @options = options
    @serializer = options.serializer
  end

  def log
    @log ||= Log.new
  end

  def parse_links str
    # resolve_links fails when a link is defined above the object containing the item the link is pointing to
    objects_list = [@object]
    objects_list += @object.children
    err = nil
    objects_list.each do |obj|
      @object = obj
      begin
        str = resolve_links str
        return str
      rescue => e
        if e.message.match /In file [\s\w\d`\/\.:']*Cannot resolve link to \S+ from text:/
          err = e
          next
        else
          YARD::Logger.instance.warn e.message
          return str
        end
      ensure
        reset_object
      end
    end
    YARD::Logger.instance.warn err.message if err

    str
  end

  alias_method :original_url_for, :url_for

  def url_for obj, anchor = nil, relative = true
    if obj.is_a? YARD::CodeObjects::Base
      unless obj.is_a? YARD::CodeObjects::NamespaceObject
        # If the obj is not a namespace obj make it the anchor.
        anchor = obj
        obj = obj.namespace
      end
      link = obj.path.sub(/^::/, "").gsub("::", "-")
      result = link + (anchor ? "#" + urlencode(anchor_for(anchor)) : "")
      return result
    end

    original_url_for obj, anchor, relative
  end

  alias_method :original_link_url, :link_url

  def link_url url, title = nil, params = {}
    title ||= url
    title.gsub! "_", "&lowbar;"
    original_link_url url, title, params
  end

  def anchor_for obj
    anchor = obj.path.tr "?!:#\.", "_"
    if obj.type == :method
      anchor += obj.scope == :class ? "_class_" : "_instance_"
    end
    anchor
  end

  def reset_object
    @object = @original_object
  end
end

class RADCarpetHTML < Redcarpet::Render::HTML
  def initialize render_options = {}, min_header: nil, toplevel_header: false
    super render_options
    @min_header = min_header
    @toplevel_header = toplevel_header
  end

  def header text, header_level
    if @min_header
      if @toplevel_header
        header_level += @min_header - 1
      else
        header_level = 2 if header_level == 1
        header_level += @min_header - 2
      end
    end
    header_level = 5 if header_level > 5
    "<h#{header_level}>#{text}</h#{header_level}>\n"
  end
end

def markdown str, renderer
  redcarpet = Redcarpet::Markdown.new renderer, no_intra_emphasis: true, lax_spacing: true
  str = redcarpet.render str
  while str.end_with? "\n"
    str = str[0..-2]
  end
  unparagraph str
end

def docstring obj
  str = pre_format obj.docstring.to_str, min_header: 4
end

def escapes str
  str = str.gsub /(?!\\)"/, '\"'
  str.gsub /(?!\\)\n/, '\n'
end

def pre_format str, min_header: nil, toplevel_header: false
  str = str.to_s
  renderer = RADCarpetHTML.new min_header: min_header, toplevel_header: toplevel_header
  str = markdown str, renderer
  str = Formatter.new(@object, @options).parse_links str
  str = escapes str
  str = fix_googleapis_links str
  str
end

def unparagraph str
  if str.start_with?("<p>") && str.end_with?("</p>")
    str = str[3..-5]
  end
  str
end

def fix_googleapis_links str
  str.gsub /http.*googleapis.dev\/ruby\/(google-cloud.*\))/, 'https://cloud.devsite.corp.google.com/ruby/docs/reference/\1'
end

def link_objects str
  return str if str.empty?
  url = str
  splitables = ["<", ">", ","]
  obj = object_match url, str
  if obj
    link object_url(obj), str
  elsif splitables.any? { |a| str.include? a }
    seps = []
    parts = []
    last_part = ""
    str.chars.each do |a|
      if splitables.include? a
        parts << last_part
        seps << a
        last_part = ""
      else
        last_part += a
      end
    end
    parts << last_part
    seps.map! { |a| CGI::escapeHTML a }
    new_str = link_objects(parts.shift)
    until seps.empty?
      new_str += seps.shift
      new_str += link_objects(parts.shift)
    end
    new_str
  else
    str
  end
end

def object_match str, t
  str = str[2...str.size] if str.start_with? "::"
  matches = object_list.select { |obj| obj.path == str }
  return matches.first unless matches.empty?

  matches = object_list.select { |obj| obj.path.end_with? str }
  if matches.size > 1
    matches.select! { |obj| obj.path.start_with? @object.path }
  end
  return matches.first unless matches.empty?
  
  matches = children_list.select { |obj| obj.path.end_with? str }
  matches.select! { |obj| obj.name == str.split("#").last.split(".").last }
  return matches.first unless matches.empty?
  nil
end

def object_url obj
  if object_list.include? obj
    return "./#{obj.path.gsub "::", "-"}"
  elsif children_list.include? obj
    url = "./#{obj.parent.path.gsub "::", "-"}#"
    anchor = obj.path.gsub(":", "_").gsub(".", "_").gsub("#", "_")
    if obj.type == :method
      sign = obj.path[obj.path.size - obj.name.to_s.size - 1]
      if sign == "."
        anchor += "_class_"
      else
        anchor += "_instance_"
      end
    end
    return url + anchor
  else
    raise "Unable to find object: #{obj.path}"
  end
end

def in_codeblock? str, sub_str, i
  return false unless str.include?(code_head) && str.include?(code_tail)

  i += sub_str.size
  while i < str.size
    return false if code_head == str[i...(i + code_head.size)]
    return true if code_tail == str[i...(i + code_tail.size)]

    i += 1
  end
  false
end

def code_head
  "<pre class=\\\"prettyprint lang-rb\\\">"
end

def code_tail
  "</pre>"
end

def codeblock str
  code_head + str + code_tail
end

def link url, str
  "<a href=\\\"#{url}\\\">#{CGI::escapeHTML str}</a>"
end
