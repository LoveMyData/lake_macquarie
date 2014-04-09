require 'scraperwiki'
require 'mechanize'

module PlanningAlertsXMLFeed
  def self.scrape(url, verbose = false)
    agent = Mechanize.new

    page = Nokogiri::XML(agent.get(url).body)

    page.search("application").each do |app|
      record = {
        "council_reference" => app.at("council_reference").inner_text,
        "address" => app.at("address").inner_text,
        "description" => app.at("description").inner_text,
        "info_url" => app.at("info_url").inner_text,
        "comment_url" => app.at("comment_url").inner_text,
        "date_scraped" => Date.today.to_s
      }
      # Optional fields
      record["date_received"] = app.at("date_received").inner_text if app.at("date_received")
      record["on_notice_from"] = app.at("on_notice_from").inner_text if app.at("on_notice_from")
      record["on_notice_to"] = app.at("on_notice_to").inner_text if app.at("on_notice_to")
      p record if verbose
      if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
        ScraperWiki.save_sqlite(['council_reference'], record)
      else
        puts "Skipping already saved record " + record['council_reference'] if verbose
      end
    end
  end
end

PlanningAlertsXMLFeed.scrape("http://www.lakemac.com.au/da_submitted.aspx?datespan=past14days")
