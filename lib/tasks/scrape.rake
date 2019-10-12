require 'open-uri'

namespace :scrape do
    desc 'scrape for all locations'
    task :scrape_all => :environment do
        is_first_loop = true
        locations.each_with_index do |location, i|
            if is_first_loop

                loop_start_time = Time.now
                Rake::Task["scrape:scrape_stars"].invoke(location)
                loop_one_time = Time.now - loop_start_time
                
                total_estimated_time = 47*(loop_one_time)
                puts "====================================================================="
                puts "推定所要時間:#{(total_estimated_time/60).floor()}分#{(total_estimated_time%60).floor()}秒"
                puts "====================================================================="
                is_first_loop = false
            else
                Rake::Task["scrape:scrape_stars"].reenable
                Rake::Task["scrape:scrape_stars"].invoke(location)
                puts "====================================================================="
                puts "全体進捗: #{(100*i/47).floor(2)}%完了"
                puts "====================================================================="
            end
        end
        Rake::Task["scrape:create_all_prefectures_summary"].invoke()
    end

    desc 'scraping tabelog stars data from tabelog.com'
    task :scrape_stars,['location'] => :environment do |task, arg|

        start_time = Time.now
        base_url = "https://tabelog.com/"
        location_url = base_url + arg.location + "/rstLst/"
        charset = nil
        error_interval = 0
        is_first_loop = true

        # calculate the number of times to fetch all restaurant
        puts "location:" + arg.location + "を取得します"

        # limited to 59 pages
        pages = 59

        # loop and get name, star, link from tabelog
        pages.times do |page_count|
            loop_start_time = Time.now if is_first_loop
            begin 
                url = location_url + "#{page_count+1}/"
                fetched = open(url) do |data|
                    data.read
                end
            rescue => e
                puts e
                error_interval += 30
                puts "#{error_interval}秒経ってからリトライします..."
                sleep(error_interval)
                retry
            end

            doc = Nokogiri::HTML.parse(fetched, nil, charset)
            names   = doc.xpath("//a[@class='list-rst__rst-name-target cpy-rst-name']/text()")
            stars   = doc.xpath("//span[@class='c-rating__val c-rating__val--strong list-rst__rating-val']/text()")
            links   = doc.xpath("//a[@class='list-rst__rst-name-target cpy-rst-name']/@href")
            reviews = doc.xpath("//em[@class='list-rst__rvw-count-num cpy-review-count']")
            
            name_array = names.map do |name|
                name.text
            end
            star_array = stars.map do |star|
                star.text.to_f
            end
            link_array = links.map do |link|
                link.text
            end
            reviews_array = reviews.map do |review|
                review.text.to_i
            end

            # create hash with header
            restaurant_record = name_array.zip(star_array, link_array, reviews_array)
            header = ["name", "star", "link", "review"]
            restaurant_record.map do |row|
                restaurant_data = Hash[*header.zip(row).flatten]
                
                # create or update
                restaurant = Restaurant.find_or_initialize_by(link: restaurant_data["link"])
                restaurant.update_attributes(
                    name: restaurant_data["name"],
                    star: restaurant_data["star"],
                    link: restaurant_data["link"],
                    reviews: restaurant_data["review"],
                    location: arg.location
                )
            end
            sleep(1.0)
            puts "location:#{arg.location}の取得 #{(100*page_count.to_f/pages.to_f).floor(2)}%完了..."

            # calc estimated time at first loop
            if is_first_loop
                loop_end_time = Time.now
                loop_one_time = loop_end_time - loop_start_time
                total_estimated_time = loop_one_time*pages
                puts "location:#{arg.location}取得の推定所要時間：約#{(total_estimated_time/60).floor()}分#{(total_estimated_time%60).floor()}秒"
                is_first_loop = false
            end
        end

        puts "summaryを作成中..."
        Rake::Task["scrape:create_summary"].reenable
        Rake::Task["scrape:create_summary"].invoke(arg.location)
        puts "location:" + arg.location + "の取得とsummaryの作成を完了\n"
    end

    desc 'create summary data'
    task :create_summary,['location'] => :environment do |task, arg|
        detailed_summary_data = {}
        summary_data = {}
        count_summary = 0

        reviews_threshold = [0,30,50]
        reviews_threshold.each do |threshold|
            500.times do |i|
                star  = i.to_f/100
                count = Restaurant.where("star LIKE #{star}")
                                  .where(location: arg.location)
                                  .where("reviews >= #{threshold}").count
                count_summary = count_summary + count
                detailed_summary_data.merge!({star => count})
                if i%10 == 9
                    # e.g if star = 2.89, the data contains from 2.80~2.89 
                    # the data contains 0.00 ~ 4.99
                    summary_data.merge!({"#{star}~#{(star-0.09).floor(2)}" => count_summary})
                    count_summary = 0
                end
            end
            Summary.create(summary_data: detailed_summary_data.to_s, summary_type: "detailed", location: arg.location,\
                data_description: "more than or equal to #{threshold}")
            Summary.create(summary_data: summary_data.to_s, summary_type: "aggregated", location: arg.location,\
                data_description: "more than or equal to #{threshold}")
        end


    end

    desc 'create all summary'
    task :create_all_summary => :environment do
        locations.each_with_index do |location, i|
            puts 'location:' + location + 'のサマリーを作成中'
            Rake::Task["scrape:create_summary"].reenable
            Rake::Task["scrape:create_summary"].invoke(location)
        end

    end

    desc 'create all prefectures summary'
    task :create_all_prefectures_summary => :environment do
        reviews_threshold.each do |threshold|
            accumlated_summary_data = {}
            locations.each do |location|
                summary_data = eval(Summary.where(location: location, summary_type: "detailed",\
                data_description: "more than or equal to #{threshold}").last.summary_data)
                accumlated_summary_data.merge!(summary_data){|k, v1, v2| v1 + v2}
            end
            Summary.create(summary_data: accumlated_summary_data.to_s, summary_type: "47prefectures_detailed",\
                data_description: "more than or equal to #{threshold}")
        end
    end

    def reviews_threshold
        threshold = [0,30,50]
    end

    def locations
        Location.all.pluck(:location)
    end
end
