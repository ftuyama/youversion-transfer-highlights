require_relative 'lib/transfer'

class Stats
  def run
    transfer = Transfer.new
    transfer.load_highlights
    references = transfer.get_references_to_transfer

    books = references.map { |r| r['human'].match(/^\d*\s*(\D+)/).to_s }

    puts (books.tally.sort_by { |k, v| -1 * v }.map do |element, count|
      "#{element.ljust(20)}  #{'#' * count} (#{count})"
    end.join("\n"))
  end
end

Stats.new.run
