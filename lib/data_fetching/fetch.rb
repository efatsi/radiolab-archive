require 'json'
require 'awesome_print'

def get_response(page)
  puts "Fetching page: #{page}"

  url = query_url(page)
  response = `#{url}`

  sleep(rand(4) + 2)
  JSON.parse(response)
end

def query_url(page)
  <<-URL
  curl 'https://kxhzn32iej-dsn.algolia.net/1/indexes/radiolab/query?x-algolia-agent=Algolia%20for%20JavaScript%20(4.14.3)%3B%20Browser%20(lite)&x-algolia-api-key=de333220c1122b2270b098cf2486f668&x-algolia-application-id=KXHZN32IEJ' \
  -H 'Accept: */*' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Origin: https://radiolab.org' \
  -H 'Referer: https://radiolab.org/' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: cross-site' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X rand(10) + 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'sec-ch-ua: "Not_A Brand";v="99", "Google Chrome";v="109", "Chromium";v="109"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  --data-raw '{"query":"","page":#{page},"filters":""}' \
  --compressed
  URL
end

@episodes = []

def fetch_episodes
  page = 0

  initial_response = get_response(page)
  @episodes = initial_response["hits"]

  pages = initial_response["nbPages"]
  page += 1

  while page < pages
    response = get_response(page)
    @episodes += response["hits"]

    page += 1
  end
end

def print_it
  @episodes.sort_by { |episode| episode["publish-at"] }.each do |episode|
    puts "  - #{episode["title"]}"
    puts "    #{episode["tease"]}"
    puts "    #{episode["publish-at"]}"
    puts "    #{episode["audio"]}"
    puts
  end

  puts "DONE!"
end

fetch_episodes()
print_it()
