class LandingController < ApplicationController
  def index
    if Current.usuario
      redirect_to dashboard_path
    else
      redirect_to login_path
    end
  end
end
