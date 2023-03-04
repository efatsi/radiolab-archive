require "open-uri"
load "data/episodes.rb"

@failed = []

def download
  @episodes.sort_by { |episode| episode["publish-at"] }.each do |episode|
    begin
      filepath = "audios/#{episode['slug']}.mp3"

      if File.exist?(filepath)
        next
      end

      if episode["audio"].nil?
        # video, track down manually w/ youtube
        next
      end

      puts "  - pulling #{episode["title"]} (#{episode["publish-at"]})"

      audio_url = episode["audio"].gsub("https://www.podtrac.com/pts/redirect.mp3/", "")
      tempfile = URI.open(audio_url)
      FileUtils.cp(tempfile.path, filepath)
    rescue => e
      puts "    - failed (#{e})"
      @failed << {
        error: e,
        episode: episode
      }
    end
  end

  puts "Done!"
end

download()
