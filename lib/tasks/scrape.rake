require 'open-uri'

namespace :scrape do
    desc 'scraping tabelog stars data from tabelog.com'
    task :scrape_stars, :environment do |task, location|
=begin
        location
            tokyo
            kanagawa
            aichi
            osaka
            kyoto
            fukuoka
=end

        base_url = "https://tabelog.com/"
        location_url = base_url + location + "/rstLst/"
        picked_data = []
        charset = nil

        # calculate fetching time
        pages = open(location_url) do |data|
            charset = data.charset
            doc = Nokogiri::HTML.parse(data.read, nil, charset)
            doc.xpath("//span[@class='list-condition__count']/text()").text.to_i / 20 + 1
        end

        # loop and get name, star, link from tabelog
        pages.times do |page_count|
            url = location_url + "#{page_count+1}/"
            fetched = open(url) do |data|
                data.read
            end

            doc = Nokogiri::HTML.parse(fetched, nil, charset)
            names = doc.xpath("//a[@class='list-rst__rst-name-target cpy-rst-name']/text()")
            stars = doc.xpath("//span[@class='c-rating__val c-rating__val--strong list-rst__rating-val']/text()")
            links = doc.xpath("//a[@class='list-rst__rst-name-target cpy-rst-name']/@href")
            
            name_array = names.map do |name|
                name.text
            end
            star_array = stars.map do |star|
                star.text.to_f
            end
            link_array = links.map do |link|
                link.text
            end

            # create hash with header
            names_stars_links = name_array.zip(star_array, link_array)
            header = ["name", "star", "link"]
            hashed_names_stars_links = names_stars_links.map do |row|
                Hash[*header.zip(row).flatten]
            end

            #stack data
            picked_data.append(hashed_names_stars_links)
            sleep(0.8)
        end
        picked_data.flatten!
    end
end
