require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'youtube-dl.rb'
require 'streamio-ffmpeg'
require 'tty-spinner'
require 'tty-cursor'
require 'colorize'
require 'colorized_string'

class Track

  def initialize(search)
    @term = search
    @links = []
    @song_choice = ""
    @song_choice_name = ""
    @spinner = TTY::Spinner.new(":spinner Downloading ...".colorize(:light_magenta), format: :arc)
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
    # puts @song_choice

    options = {
      extract_audio: "true",
      audio_format: "mp3",
      no_part: "true",
      output: "/Users/brycewendelaar/Music/iTunes/iTunes\ Media/Exports/%(title)s" + ".%(ext)s"
    }
    @spinner.auto_spin
    YoutubeDL.download @song_choice, options
    File.rename "/Users/brycewendelaar/Music/iTunes/iTunes\ Media/Exports/#{@song_choice_name}.mp3", "/Users/brycewendelaar/Music/iTunes/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized/#{@song_choice_name}.mp3"

    @spinner.stop("Audio Extracted".colorize(:light_cyan))
    puts "Song imported to iTunes".colorize(:light_cyan)
    puts ""
    puts "                               __              ".colorize(:light_magenta)
    puts "                             .d$$b             ".colorize(:light_magenta)
    puts "                           .' TO$;\            ".colorize(:light_magenta)
    puts "                          /  : TP._            ".colorize(:light_magenta)
    puts "                         / _.;  :Tb|           ".colorize(:light_magenta)
    puts "                        /   /   ;j$j           ".colorize(:light_magenta)
    puts "                    _.-''       d$$$           ".colorize(:light_magenta)
    puts "                  .'' ..       d$$$$;          ".colorize(:light_magenta)
    puts "                 /  /P'      d$$$$P. |\        ".colorize(:light_magenta)
    puts "                /   ''      .d$$$P' |\^'l      ".colorize(:light_magenta)
    puts "              .'           `T$P^'''''  :       ".colorize(:light_magenta)
    puts "          ._.'      _.'                ;       ".colorize(:light_magenta)
    puts "       `-.-''.-'-' ._.       _.-''   .-'       ".colorize(:light_magenta)
    puts "     `.-' _____  ._              .-''          ".colorize(:light_magenta)
    puts "    -(.g$$$$$$$b.              .'              ".colorize(:light_magenta)
    puts "     '''^^T$$$P^)            .(:               ".colorize(:light_magenta)
    puts "        _/  -''  /.'         /:/;              ".colorize(:light_magenta)
    puts "     ._.'-'`-'  '')/         /;/;              ".colorize(:light_magenta)
    puts "  `-.-''..--''   '' /         / ;              ".colorize(:light_magenta)
    puts " .-'' ..--''        -'          :              ".colorize(:light_magenta)
    puts " ..--''--.-'         (\      .-(\              ".colorize(:light_magenta)
    puts "   ..--''              `-\(\/;`                ".colorize(:light_magenta)
    puts "     _.                      :                 ".colorize(:light_magenta)
    puts "                             ;`-               ".colorize(:light_magenta)
    puts "                            :\                 ".colorize(:light_magenta)
    puts "                           ;                   ".colorize(:light_magenta)
  end

  def print_results
    video_details
    puts ""
    puts "Enter choice number...".colorize(:light_cyan)
    puts "('n' for new search | 'x' to quit)".colorize(:light_cyan)
    puts ""
    @links.each_with_index do |k, i|
      puts " [#{i + 1}] ".colorize(:light_cyan) + "#{k.first[0]}".colorize(:light_magenta)
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
    puts ""
    puts "Search for a song... ('x' to quit)".colorize(:light_cyan)
    puts ""
    search_phrase = gets.chomp
    if (search_phrase == "x")
      puts "Goodbye!"
      puts ""
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
