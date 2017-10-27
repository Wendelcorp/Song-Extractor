require 'rubygems'
require 'nokogiri'
require 'open-uri'

@links = []

def video_details(link)
  page = Nokogiri::HTML(open(link))
  page.xpath('//h3/a').first(7).each_with_index do |node, i|
    if (node.values.first.start_with?('https://googleads') || (node.values.first.include? "list=" ))
    else
      @links << {node.values[3] => node.values.first}
    end
	end
end

def print_results
  puts ""
  puts ""
  @links.each_with_index do |k, i|
    puts "Result #{i + 1}: " + k.first[0]
  end
  puts ""
  puts ""
end

def link_constructor(index)
  puts "https://www.youtube.com/" + @links[index].first[1]
end

search_prefix = "https://www.youtube.com/results?search_query="
search_phrase = gets.chomp.gsub!(/ /, "+")
video_details(search_prefix + search_phrase)
print_results
selected_video = gets.chomp.to_i - 1
link_constructor(selected_video)
