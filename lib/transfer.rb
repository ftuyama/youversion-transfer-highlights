require_relative 'api'

class Transfer
  def initialize
    @api = API.new
    @config = JSON.parse(File.read('config.json'))
  end

  def load_highlights
    @highlights = JSON.parse(File.read('highlights.json'))
  rescue
    @highlights = fetch_highlights

    File.open('highlights.json', 'w') do |file|
      file.write(JSON.pretty_generate(@highlights))
    end
  end

  def fetch_highlights
    page = 0
    @highlights = []

    loop do
      puts "Fetching highlight page ##{page + 1} ..."

      page_highlights = @api.fetch_highlights(page += 1)

      break if page_highlights && page_highlights.is_a?(Hash) && page_highlights["errors"]

      @highlights += page_highlights['moments']
    end

    @highlights
  end

  def references_from_version_id(version_id)
    @highlights.map do |h|
      next if !h.dig('extras', 'references')

      h['extras']['references'].map do |r|
        if r['version_id'] == version_id
          r.merge({
            'color' => h['extras']['color']
          })
        end
      end
    end.flatten.compact.uniq { |r| r['human'] }
  end

  def get_references_to_transfer
    origin_references = references_from_version_id(@config['origin_version_id'])
    target_references = references_from_version_id(@config['target_version_id'])

    existing_references = target_references.map { |r| r['human'] }

    @references = origin_references.reject { |r| existing_references.include?(r['human']) }
  end

  def transfer_references
    @references.each_with_index do |r, i|
      puts "Creating reference #{i}/#{@references.count} ... #{r['human']}"

      response = @api.create_hightlight(r['color'], r['usfm'])

      raise response.to_s if response['errors']
    end
  end

  def run
    load_highlights
    get_references_to_transfer
    transfer_references
  end
end
