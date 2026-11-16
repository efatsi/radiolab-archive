require "net/http"
require "json"

# Pulls episodes from radiolab.org's public Algolia search index (the same
# source lib/data_fetching/fetch.rb used for the original import).
module RadiolabImport
  ALGOLIA_URL = URI("https://kxhzn32iej-dsn.algolia.net/1/indexes/radiolab/query")
  ALGOLIA_PARAMS = {
    "x-algolia-application-id" => "KXHZN32IEJ",
    "x-algolia-api-key" => "de333220c1122b2270b098cf2486f668",
  }

  module_function

  # All hits published after `since` (a Time), across every result page.
  def fetch_since(since)
    filters = "date-line-ts > #{since.to_i}"
    hits = []
    page = 0

    loop do
      response = query(page: page, filters: filters)
      hits.concat(response.fetch("hits"))
      page += 1
      break if page >= response.fetch("nbPages")
      sleep 1
    end

    hits
  end

  def query(page:, filters:)
    uri = ALGOLIA_URL.dup
    uri.query = URI.encode_www_form(ALGOLIA_PARAMS)

    request = Net::HTTP::Post.new(uri)
    request["Origin"] = "https://radiolab.org"
    request["Referer"] = "https://radiolab.org/"
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.body = { query: "", page: page, hitsPerPage: 100, filters: filters }.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    raise "Algolia request failed (#{response.code}): #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  # Like lib/data_fetching/download.rb: skip the podtrac tracking redirect,
  # which can bounce https -> http and make open-uri refuse it. Newer feed
  # URLs nest it behind other trackers and drop the scheme, e.g.
  #   https://chrt.fm/track/X/pdst.fm/e/www.podtrac.com/pts/redirect.mp3/waaa.wnyc.org/a.mp3
  def direct_audio_url(url)
    rest = url.split("podtrac.com/pts/redirect.mp3/", 2)[1]
    return url if rest.blank?

    rest.match?(%r{\Ahttps?://}) ? rest : "https://#{rest}"
  end

  # Phrases in a description that mean the episode is a rerun. Kept narrow:
  # plain "originally" also shows up in corrections ("we originally reported…").
  REPLAY_HINT = /
    \b(originally|first)\s+(aired|ran|broadcast|podcast)\b |
    \boriginally\s+(posted|published|released)\s+(this\s+episode|in\s+(19|20)\d\d|on\s+\w+\s+\d) |
    \brebroadcast |
    \bfrom\s+the\s+(radiolab\s+)?(archives?|vault)\b |
    \bencore\b |
    \breplay(ing)?\b
  /ix

  # "Radiolab Presents: More Perfect - The Gun Show" and
  # "More Perfect: The Gun Show" both become "more perfect gun show".
  def normalize_title(title)
    ActionController::Base.helpers.strip_tags(title.to_s).downcase
      .sub(/\A(update|radiolab presents|rebroadcast|replay|encore)\s*:\s*/, "")
      .gsub("&", " and ")
      .gsub(/[^a-z0-9]+/, " ")
      .gsub(/\b(the|a|an)\b/, " ")
      .squish
  end

  def replay_hint(description)
    ActionController::Base.helpers.strip_tags(description.to_s).squish[REPLAY_HINT]
  end

  # Earliest episode published before `episode` with the same normalized title.
  # `known` is every episode seen so far, oldest first.
  def find_original(episode, known)
    title = normalize_title(episode.title)
    known.find do |other|
      other.slug != episode.slug &&
        other.publish_at < episode.publish_at &&
        normalize_title(other.title) == title
    end
  end

  # Same field mapping as playground/scratch.rb#jsonify_seeds.
  def attributes_for(hit)
    {
      title: hit["title"].to_s.strip,
      tease: hit["tease"].to_s.strip,
      description: hit["description"].to_s.strip,
      audio_url: hit["audio"].is_a?(String) ? hit["audio"] : nil,
      publish_at: Time.parse(hit["publish-at"]),
      image_url: hit.dig("image-main", "url"),
      length: hit["estimated-duration"],
    }
  end
end

namespace :episodes do
  desc "Import episodes published since the newest one in the DB. DRY_RUN=1 to preview, SINCE=2023-01-01 to override the start date."
  task import: :environment do
    latest = Episode.first # default_scope orders by publish_at desc
    since = ENV["SINCE"] ? Time.zone.parse(ENV["SINCE"]) : latest&.publish_at || Time.at(0)
    dry_run = ENV["DRY_RUN"].present?

    puts "Newest episode in DB: #{latest ? "#{latest.title} (#{latest.publish_at.to_date})" : "none"}"
    puts "Fetching episodes published after #{since}..."

    hits = RadiolabImport.fetch_since(since).sort_by { |hit| hit["publish-at"] }
    created = updated = skipped = replays = 0
    known = Episode.reorder(:publish_at).to_a # grows as we go, so reruns within this batch match too

    hits.each do |hit|
      slug = hit["slug"].to_s.strip
      if slug.blank? || hit["publish-at"].blank?
        skipped += 1
        next
      end

      episode = Episode.find_or_initialize_by(slug: slug)
      episode.assign_attributes(RadiolabImport.attributes_for(hit))
      label = episode.new_record? ? "new" : "update"
      puts "  [#{label}] #{episode.publish_at.to_date}  #{episode.title}  (#{slug})"
      puts "           no audio in feed (probably a video)" if episode.audio_url.nil?

      original = RadiolabImport.find_original(episode, known)
      hint = RadiolabImport.replay_hint(episode.description)
      episode.replay = original.present? || hint.present?
      episode.original_episode = original
      known << episode unless known.include?(episode)

      if episode.replay?
        replays += 1
        puts "           REPLAY of #{original.title} (#{original.publish_at.to_date}, #{original.slug})" if original
        puts "           REPLAY: description says \"#{hint}\"#{" (no matching title in archive)" unless original}" if hint
      end

      next if dry_run || !episode.changed?

      episode.new_record? ? created += 1 : updated += 1
      episode.save!
    end

    if dry_run
      puts "DRY RUN: #{hits.size} found (#{replays} replays), nothing saved."
    else
      puts "Done: #{created} created, #{updated} updated, #{skipped} skipped, #{replays} replays. #{Episode.count} total."
    end
  end

  desc "Download mp3s for episodes missing from DIR (default public/audios), named <slug>.mp3 for upload to the audio host."
  task download_audio: :environment do
    require "open-uri"

    dir = Pathname(ENV.fetch("DIR", Rails.root.join("public/audios").to_s))
    FileUtils.mkdir_p(dir)
    scope = ENV["SINCE"] ? Episode.where("publish_at > ?", Time.zone.parse(ENV["SINCE"])) : Episode.all

    scope.reorder(:publish_at).each do |episode|
      path = dir.join("#{episode.slug}.mp3")
      source = episode.read_attribute(:audio_url) # bypass the model's hosted-URL override
      next if path.exist? || source.blank?

      puts "  - #{episode.title} (#{episode.publish_at.to_date})"
      URI.open(RadiolabImport.direct_audio_url(source), "rb") { |remote| IO.copy_stream(remote, path.to_s) }
    rescue => e
      puts "    failed: #{e.message}"
      FileUtils.rm_f(path) if path
    end
  end
end
