require "uri"
require "net/http"
require "json"

class API
  def initialize
    @config = JSON.parse(File.read('config.json'))
  end

  def create_hightlight(color, usfm)
    url = URI("https://nodejs.bible.com/api_auth/moments/create/3.1")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = @config['authorization']
    request["Cookie"] = "locale=#{@config['language']}"
    request.body = JSON.dump({
      "kind": "highlight",
      "references": [
        {
          "usfm": usfm,
          "version_id": @config['target_version_id']
        }
      ],
      "color": color,
      "created_dt": Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z')
    })

    response = https.request(request)
    JSON.parse(response.read_body)
  end

  def fetch_highlights(page=1)
    url = URI("https://nodejs.bible.com/api_auth/moments/items/3.1?page=#{page}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = @config['authorization']
    request["Cookie"] = "locale=#{@config['language']}"

    response = https.request(request)
    JSON.parse(response.read_body)
  end
end
