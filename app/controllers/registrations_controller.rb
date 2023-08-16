class RegistrationsController < Devise::RegistrationsController

	def create
		
		tenant_params = sign_up_params_tenant
		user_params   = sign_up_params_user.merge({ is_admin: true })
		coupon_params = nil

		sign_out_session!
		
		prep_signup_view( tenant_params, user_params, coupon_params )

          Tenant.transaction  do 
              @tenant = Tenant.create(tenant_params)
              if @tenant.errors.empty? 
                  if @tenant.plan == 'premium'
						@payment = Payment.new({ 
                            email: user_params["email"],
                            token: params[:payment]["token"],
                            tenant: @tenant })
						flash[:error] = "Please check registration errors" unless @payment.valid?
                        # binding.irb
						begin
							@payment.process_payment
							@payment.save
						rescue Exception => e 
							flash[:error] = e.message
							@tenant.destroy
							log_action("Payment failed")
							render :new and return
						end
					end
              else
                  resource.valid?
                  log_action( "tenant create failed", @tenant )
                  render :new
              end 
        
              if flash[:error].blank? || flash[:error].empty? 
                  
                  session[:tenant_id] = @tenant.id
                  user_params[:tenants] = [@tenant]
                  devise_create( user_params )
              else
                  resource.valid?
                  log_action("Payment processing failed", @tenant )
                  render :new and return
              end 
          end 
      

  end   



    protected
    def configure_permitted_parameters
    
        p "configure_permitted_parameters - XXXXX"
        devise_parameter_sanitizer.for(:sign_up).push(:payment)
    end

    def sign_up_params_tenant()
      params.require(:tenant).permit( :name, :plan )
    end

    def sign_up_params_user()
      params.require(:user).permit( :email, :password, :password_confirmation )
    end

    def sign_up_params_coupon()
      ( ::Milia.use_coupon ? 
        params.require(:coupon).permit( ::Milia.whitelist_coupon_params )  :
        params
      )
    end

 
    def sign_out_session!()
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name) if user_signed_in?
    end

    def devise_create( user_params )

      build_resource(user_params)

          resource.skip_confirm_change_password  = true


      if resource.save
          yield resource if block_given?
          log_action( "devise: signup user success", resource )
          if resource.active_for_authentication?
              set_flash_message :notice, :signed_up if is_flashing_format?
              sign_up(resource_name, resource)
              respond_with resource, :location => after_sign_up_path_for(resource)
          else
              set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
              expire_data_after_sign_in!
              respond_with resource, :location => after_inactive_sign_up_path_for(resource)
          end
      else
          clean_up_passwords resource
          log_action( "devise: signup user failure", resource )
          prep_signup_view(  @tenant, resource, params[:coupon] )   
          respond_with resource
      end
    end

 
    def after_sign_up_path_for(resource)
      headers['refresh'] = "0;url=#{root_path}"
      root_path
    end


    def after_inactive_sign_up_path_for(resource)
      headers['refresh'] = "0;url=#{root_path}"
      root_path
    end

    def log_action( action, resource=nil )
      err_msg = ( resource.nil? ? '' : resource.errors.full_messages.uniq.join(", ") )
      logger.debug(
        "MILIA >>>>> [register user/org] #{action} - #{err_msg}"
      ) unless logger.nil?
    end

  private

  def prep_signup_view(tenant=nil, user=nil, coupon={coupon:''})
      @user   = klass_option_obj( User, user )
      @tenant = klass_option_obj( Tenant, tenant )
      @coupon = coupon
    end

    def klass_option_obj(klass, option_obj)
      return option_obj if option_obj.instance_of?(klass)
      option_obj ||= {}
      return klass.send( :new, option_obj )
  end

end