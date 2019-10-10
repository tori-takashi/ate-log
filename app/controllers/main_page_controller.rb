class MainPageController < ApplicationController
    def index
        @restraunts = Restraunt.all
    end
end
