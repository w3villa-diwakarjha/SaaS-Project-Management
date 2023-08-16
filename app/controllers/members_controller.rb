class MembersController < ApplicationController

    def new()
        @member = Member.new()
        @user   = User.new()
    end

    def create()
        @user   = User.new( user_params )
        @member = Member.new(member_params)
        @member.user = @user
        @user.tenants << current_tenant
        @member.tenant = current_tenant
  
        # ok to create user, member
        if @user.save_and_invite_member() && @member.save
          flash[:notice] = "New member added and invitation email sent to #{@user.email}."
          redirect_to root_path
        else
          flash[:error] = "errors occurred!"
          @member = Member.new( member_params ) # only used if need to revisit form
          render :new
        end
    
    end
    
    
    private
    
    def member_params()
      params.require(:member).permit(:first_name, :last_name)
    end
    
    def user_params()
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

end