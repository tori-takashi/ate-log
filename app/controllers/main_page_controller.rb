class MainPageController < ApplicationController
    def index
        @q = Restaurant.ransack(params[:q])
        @restaurants = @q.result(distinct: true).page(params[:page]).per(50)
    end
end
