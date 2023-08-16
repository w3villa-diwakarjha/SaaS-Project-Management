class HomeController < ApplicationController
  
  def index
    if current_user
      @user= current_user
      @tenant= current_user
      @projects= Project.by_user_plan_and_tenant(@tenant.id, current_user)

      params[:tenant_id]= @tenant.id
    end
  end
end
