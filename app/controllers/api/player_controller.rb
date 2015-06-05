module Api
  class PlayerController < ApplicationController

    def index
      @players = Player.all

      if params[:position]
        @players = @players.where(position: params[:position])
      end
    end

  end

end
