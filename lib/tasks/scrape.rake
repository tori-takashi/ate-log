require 'open-uri'

namespace :scrape do
    desc 'scraping tabelog stars data from tabelog.com'
    task :scrape_stars,['location'] => :environment do |task, arg|
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
        location_url = base_url + arg.location + "/rstLst/"
        charset = nil

        # calculate fetching time
        pages = open(location_url) do |data|
            charset = data.charset
            doc = Nokogiri::HTML.parse(data.read, nil, charset)
            doc.xpath("//span[@class='list-condition__count']/text()").text.to_i / 20 + 1
        end

        pages = 1

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
                restaurant_data = Hash[*header.zip(row).flatten]
                
                # create or update
                restaurant = Restaurant.find_or_initialize_by(link: restaurant_data["link"])
                restaurant.update_attributes(
                    name: restaurant_data["name"],
                    star: restaurant_data["star"],
                    link: restaurant_data["link"],
                    location: arg.location
                )
            end

            sleep(0.8)
        end
        puts Restaurant.all.size
    end

    desc 'create summary data'
    task :create_summary,['location'] => :environment do |task, arg|
        detailed_summary_data = []
        summary_data = []
        count_summary = 0

        500.times do |i|
            star  = i.to_f/100
            count = Restaurant.where(star: star, location: arg.location).count
            count_summary = count_summary + count
            detailed_summary_data.append({star => count})
            if i%10 == 9
                # e.g if star = 2.89, the data contains from 2.80~2.89 
                # the data contains 0.00 ~ 4.99
                summary_data.append({"#{star}~#{(star-0.09).floor(2)}" => count})
                count_summary = 0
            end
        end

        Summary.create(summary_data: detailed_summary_data.to_s, summary_type: "detailed", location: arg.location)
        Summary.create(summary_data: summary_data.to_s, summary_type: "aggregated", location: arg.location)

    end

end
