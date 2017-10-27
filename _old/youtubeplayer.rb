require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'youtube-dl.rb'
require 'streamio-ffmpeg'

class Track

  def initialize(link)
    @link = link
  end

  def video_details
    page = Nokogiri::HTML(open(@link))
    return page.title.gsub(/ - YouTube/, '')
  end

  def file_path
    "/Users/brycewendelaar/Desktop/_Exports/#{video_details}"
  end

  def download_video
    options = {
      extract_audio: "true",
      audio_format: "mp3",
      output: file_path + ".%(ext)s"
    }
    puts "Downloading..."
    YoutubeDL.download @link, options
    puts "Audio Extracted"
  end

  def print_link
    "Your Link = #{@link}"
  end

end

loop do
  puts "Paste a song link... ('x' to quit)"
  track = gets.chomp
  if (track == "x")
    puts "Goodbye!"
    break
  else
    new_track = Track.new(track)
    new_track.download_video
  end
end
