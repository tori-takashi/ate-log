class MainPageController < ApplicationController
    def index
        @restaurants = Restaurant.all
    end
end
