class MainPageController < ApplicationController
    def index
        @restaurants = Restaurant.page(params[:page]).per(50)
    end
end
