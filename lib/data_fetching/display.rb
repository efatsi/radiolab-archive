load "data/episodes.rb"

def episode_url(slug)
  "https://radiolab.org/episodes/#{slug}"
end

def output
  @episodes.sort_by{|e| e["publish-at"]}.each do |episode|
    File.open("data/episodes.md", "a") do |file|
      file.puts "- [#{episode["title"]}](#{episode_url(episode["slug"])})"
      file.puts "  - #{episode["tease"].gsub("&nbsp;", " ")}"
      file.puts "  - #{episode["publish-at"]}"

      if episode["audio"]
        file.puts "  - #{episode["audio"]}"
      end

      file.puts
    end
  end

  puts "Done!"
end

output
