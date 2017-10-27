require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'youtube-dl.rb'
require 'streamio-ffmpeg'
require 'tty-spinner'
require 'tty-cursor'

class Track

  def initialize(search)
    @term = search
    @links = []
    @song_choice = ""
    @song_choice_name = ""
    @spinner = TTY::Spinner.new(":spinner Loading ...", format: :arc)
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
      output: "/Users/brycewendelaar/Music/iTunes/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized/#{@song_choice_name}" + ".%(ext)s"
    }
    @spinner.auto_spin
    YoutubeDL.download @song_choice, options
    @spinner.stop("Audio Extracted")
    puts ""
  end

  def print_results
    video_details
    puts ""
    puts "Enter choice number..."
    puts "('n' for new search | 'x' to quit)"
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

def new_search
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
      selected_video = gets.chomp
      if (selected_video == "n")
        new_search
      elsif (selected_video == "x")
        break
      else
        new_track.link_constructor(selected_video.to_i - 1)
        new_track.download_video
      end
    end
  end
end

new_search
