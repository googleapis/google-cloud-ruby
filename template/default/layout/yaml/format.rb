require "redcarpet"
require "yard"

class Log
  # YARD records issues finding links via YARD::Logger#warn
  def warn str
    raise str
  end
end

class Formatter
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
    Log.new
  end

  def parse_links str
    # resolve_links fails when a link is defined above the object containing the item the link is pointing to
    objects_list = [@object]
    objects_list += @object.children
    objects_list.each do |obj|
      @object = obj
      err = nil
      begin
        str = resolve_links str
        return str
      rescue => e
        if e.message.match /In file [\s\w\d\`\/\.\:\']*Cannot resolve link to #\w+ from text\:/
          err = e
          next
        else
          YARD::Logger.instance.warn e.message
          return str
        end
      ensure
        reset_object
      end
      YARD::Logger.instance.warn e.message
    end

    str
  end

  def reset_object
    @object = @original_object
  end
end

def markdown str
  renderer = Redcarpet::Render::HTML.new(render_options = {})
  redcarpet = Redcarpet::Markdown.new renderer
  str = redcarpet.render str
  while str.end_with? "\n"
    str = str[0..-2]
  end
  unparagraph str
end

def docstring obj
  str = pre_format obj.docstring.to_str
end

def escapes str
  str = str.gsub /(?!\\)"/, '\"'
  str.gsub /(?!\\)\n/, '\n'
end

def pre_format str
  str = str.to_s
  # Parse markdown prior to running resolve_links, which checks for HTML codeblocks
  if @method && @method.path.to_s == "Google::Cloud::PubSub::Subscription#remove_dead_letter_policy"
    require "pry"
    binding.pry
  end
  str = markdown str
  # str = YARD::Templates::Helpers::HtmlHelper.resolve_links str
  str = Formatter.new(@object, @options).parse_links str
  # YARD turns {} style links into [] markdown style links. Re-parsing markdown to get HTML links.
  # str = markdown str
  str = escapes str
  # str = codeblock_space str
  # str = str.gsub("\\\\{", "{").gsub "\\{", "{"
  # str = str.gsub("\\\\}", "}").gsub "\\}", "}"
  # str = codeblock_backtick str
  # str = demote_headers str
  str = fix_googleapis_links str
  str = fix_object_links str
  # str = Formatter.resolve_links str
  
  # str = normalize_links str
  str
end



def unparagraph str
  if str.start_with?("<p>") && str.end_with?("</p>")
    str = str[3..-5]
  end
  str
end

def demote_headers str, min = 0
  # out = ""
  # match_list = []
  # i = 0
  # while i < str.size
  #   if str[(i - 1)..-1] =~ /\A(#+\s\w+)/
  #     match_list << [Regexp.last_match, i - 1]
  #     i += Regexp.last_match[0].size
  #   else
  #     i += 1
  #   end
  # end
  # return str if match_list.empty?

  # prev = 0
  # match_list.each do |entry|
  #   match = entry[0][1]
  #   i = entry[1]
  #   out += str[prev...i]

  #   if in_codeblock? str, match, i
  #     out += match
  #     prev = i + match.size
  #   else
  #     new_header = "#" + match
  #     while new_header.split(" ").first.size < min
  #       new_header = "#" + new_header 
  #     end
  #     out += new_header
  #     prev = i + match.size
  #   end
  # end

  # out += str[prev..-1]

  # out
  str
end

def fix_googleapis_links str
  str.gsub /http.*googleapis.dev\/ruby\/(google-cloud.*\))/, 'https://cloud.devsite.corp.google.com/ruby/docs/reference/\1'
end

def fix_object_links str
  # YARD's resolve_links wraps the links in a span element, which is not needed.
  # Additionally, the hrefs assume a more typical file structure, and need to be updated
  regex = /<span class=\'object_link\'><a href=\\\"([^\\\"]*)\\\" title=\\\"([^\\\"]*)\\\"\>([^<]*)<\/a><\/span>/
  while str.match(regex)
    m = Regexp.last_match
    old_link = m[0]
    file     = m[1]
    title    = m[2]
    display  = m[3]
    url = title.split(" ").first.gsub "::", "-"
    if url.include? "#"
      page, anchor = url.split("#")
      ["!", "?"].each { |sym| anchor = anchor.gsub sym, "_" }
      anchor = "#{page.gsub "-", "__"}_#{anchor}_instance_" 
      url = "#{page}##{anchor}"
    elsif url.include? "."
      page, anchor = url.split(".")
      ["!", "?"].each { |sym| anchor = anchor.gsub sym, "_" }
      anchor = "#{page.gsub "-", "__"}_#{anchor}_class_" 
      url = "#{page}##{anchor}"
    end
    new_link = link "./#{url}", display
    puts new_link
    str = str.gsub old_link, new_link
  end
  str
end


def normalize_links str
  out = ""
  match_list = []
  (0..str.length).each do |i|
    if str[(i - 1)..i] != "\\" && (str[i..-1] =~ /\A\{([\w\.\:\#\d]*)\}/ || str[i..-1] =~ /\A\{([\w\.\:\#\d]*)\s([\w\.\:\#\d\s]*)\}/)
      match_list << [Regexp.last_match, i] 
    end
  end
  return str if match_list.empty?

  prev = 0
  match_list.each do |entry|
    obj = @object.path
    match = entry[0][0]
    url = entry[0][1] || ""
    text = entry[0][2] || ""
    i = entry[1]
    out += str[prev...i]
    if url.empty? || in_codeblock?(str, match, i)
      out += match
      prev = i + match.size
      next
    end
    text = url if text.empty?
    obj = object_match url, str
    if obj
      out += link object_url(obj), text
      prev = i + match.size
    else
      out += match
      prev = i + match.size
    end
  end
  out += str[prev..-1]
  out
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

def codeblock_space str
  end_cap = "\\n\\n!!@#^%&*ZXQZXQZXQ<>?|||"
  str += end_cap
  out = ""
  match_list = []
  i = 0
  while i < str.length
    if str[i..-1] =~ /\A(\s{4}[^\*].*?)(?=\\n\\n\S)/
      match = Regexp.last_match
      match_list << [match, i] 
      i += match[0].size
    else
      i += 1
    end
  end
  return str.sub(end_cap, "") if match_list.empty?

  prev = 0
  match_list.each do |entry|
    code = entry[0][0]
    i = entry[1]
    out += str[prev...i]
    if in_bulleted_list? str, i
      out += code
      prev = i + entry[0][0].size
      next
    else
      code = code.split("\\n").map { |line| line.sub "    ", "" }.join("\\n")
      code = codeblock code
      out += code
      prev = i + entry[0][0].size
    end
  end
  out += str[prev..-1]
  out.sub end_cap, ""
end


def codeblock_backtick str
  while str.include? "```"
    str.sub! "```", code_head
    str.sub! "```", code_tail
  end
  while str.include? "`"
    a = str.index "`"
    str.sub! "`", "<code>"
    b = str.index "`"
    substr = str[(a + "<code>".size)...b]
    new_substr = substr.gsub /(?<!\\)\*/, "&#42;"
    str.sub! substr, new_substr
    str.sub! "`", "</code>"
  end
  str
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

def in_bulleted_list? str, i
  return false if i == 0

  sep = "\\n"
  lines = str.split sep
  line_number = 0
  n = 0
  lines.each do |line|
    next if n >= i
    line_number += 1
    n += (line.size + sep.size)
  end
  lines[line_number - 1].start_with? " *  "
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
