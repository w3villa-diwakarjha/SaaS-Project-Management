class ApplicationController < ActionController::Base
    before_action :authenticate_user!, except: [:index] 

    def current_tenant
        @current_tenant ||= current_user.tenants.first
        session[:tenant_id] = @current_tenant
    end
    helper_method :current_tenant

end
