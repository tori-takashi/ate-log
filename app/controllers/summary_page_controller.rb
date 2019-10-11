class SummaryPageController < ApplicationController
    def index
        location_array = Location.pluck(:location)
        # [FIX ME]resource consuming, too much SQL queries
        detailed_data_array = []
        location_array.each do |location|
            detailed_data_array.append(Summary.where(location: location, summary_type: "detailed").last)
        end
        @latest_data = detailed_data_array
    end
end
