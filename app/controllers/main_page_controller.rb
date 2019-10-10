class MainPageController < ApplicationController
    def index
        @restaurants = restaurant.all
    end
end
