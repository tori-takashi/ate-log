class SummaryPageController < ApplicationController
    def summary_with_threshold

        if params[:threshold] == "47prefectures"
            @title = "47都道府県の評価の分布"
            @summary_0   = Summary.where(summary_type: "47prefectures_detailed", data_description: "more than or equal to 0").last
            @summary_30  = Summary.where(summary_type: "47prefectures_detailed", data_description: "more than or equal to 30").last
            @summary_50  = Summary.where(summary_type: "47prefectures_detailed", data_description: "more than or equal to 50").last
        else
            params[:threshold].nil? ? threshold_value = 0 : threshold_value = params[:threshold].to_i
            detailed_data_array = []

            locations.each do |location|
                detailed_data_array.append(Summary.where(location: location, summary_type: "detailed",\
                data_description: "more than or equal to #{threshold_value}").last)
            end
            threshold_value != 0 ? @title = "レビュー数が#{threshold_value}件以上の評価の分布" : @title = ""
            @latest_data = detailed_data_array

        end
    end

    private def locations
        location_array = Location.pluck(:location)
    end
end
