class SummaryPageController < ApplicationController
    def index
        location_array = Location.pluck(:location)
        # [FIX ME]resource consuming, too much SQL queries
        aggregated_data_array = []
        location_array.each do |location|
            aggregated_data_array.append(Summary.where(location: location, summary_type: "detailed").last)
        end
        @latest_data = aggregated_data_array
    end
end
