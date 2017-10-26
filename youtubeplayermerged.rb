require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'youtube-dl.rb'
require 'streamio-ffmpeg'

class Track

  def initialize(search)
    @term = search
    @links = []
    @song_choice = ""
    @song_choice_name = ""
  end

  def video_details
    page = Nokogiri::HTML(open(@term))
    number_of_results = 0
    page.xpath('//h3/a').each_with_index do |node, i|
      if (node.values.first.start_with?('https://googleads')) || (node.values.first.include? "list=" ) || (node.values.first.include? 'UC')
      elsif (number_of_results < 5)
        number_of_results += 1
        @links << {node.values[3] => node.values.first}
      end
  	end
  end

  def download_video
    puts @song_choice
    options = {
      extract_audio: "true",
      audio_format: "mp3",
      output: "/Users/brycewendelaar/Desktop/_Exports/#{@song_choice_name}" + ".%(ext)s"
    }
    puts "Downloading..."
    YoutubeDL.download @song_choice, options
    puts "Audio Extracted"
  end

  def print_results
    video_details
    puts ""
    puts "Enter choice number"
    puts ""
    @links.each_with_index do |k, i|
      puts " #{i + 1}: " + k.first[0]
    end
    puts ""
    puts ""
  end

  def link_constructor(index)
    @song_choice = "https://www.youtube.com" + @links[index].first[1]
    @song_choice_name = @links[index].first[0]
  end

end

loop do
  puts "Search for a song... ('x' to quit)"
  search_phrase = gets.chomp
  if (search_phrase == "x")
    puts "Goodbye!"
    break
  else
    search_phrase.gsub!(/ /, "+")
    search_prefix = "https://www.youtube.com/results?search_query="
    new_track = Track.new(search_prefix + search_phrase)
    new_track.print_results
    selected_video = gets.chomp.to_i - 1
    new_track.link_constructor(selected_video)
    new_track.download_video
  end
end