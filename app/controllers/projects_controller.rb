class ProjectsController < ApplicationController
    before_action :set_project, only: %i[ show edit update destroy users add_user]
    before_action :set_tenant, only: [:show, :edit, :update, :destroy, :new, :create, :users, :add_user]
    before_action :verify_tenant
  
    
    def index
      @projects = Project.by_user_plan_and_tenant(params[:tenant_id], current_user)
    end
  
    
    def show
    end
  
    
    def new
      @project = Project.new
    end
  
    
    def edit
    end
  
    
    def create
      @project = Project.new(project_params)
      @project.users << current_user
  
      respond_to do |format|
        if @project.save
          format.html { redirect_to root_url, notice: "Project was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end
  
    
    def update
      respond_to do |format|
        if @project.update(project_params)
          format.html { redirect_to root_url(@project), notice: "Project was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end
  
    
    def destroy
      @project.destroy
  
      respond_to do |format|
        format.html { redirect_to root_url, notice: "Project was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    def users
      
      @project_users = (@project.users + (User.joins(:tenants).where(is_admin: true, tenants: { id: @tenant.id}))) - [current_user]
      @other_users = @tenant.users.where(is_admin: false) - (@project_users + [current_user])
    end
  
    def add_user
      @project_user = UserProject.new(user_id: params[:user_id], project_id: @project.id)
  
      respond_to do |format|
        if @project_user.save
          format.html { redirect_to users_tenant_project_url(id: @project.id, tenant_id: @project.tenant_id), notice: 'User was successfully added to project' }
        else
          format.html { redirect_to users_tenant_project_url(id: @project.id, tenant_id: @project.tenant_id), error: 'User was not added to project' }
        end
      end
    end
  
    private
      
      def set_project
        @project = Project.find(params[:id])
      end
  
      
      def project_params
        params.require(:project).permit(:title, :details, :expected_completion_date, :tenant_id)
      end
  
      def set_tenant
        @tenant = Tenant.find(params[:tenant_id])
      end
  
      def verify_tenant
        
        unless params[:tenant_id] == current_tenant.id.to_s
          redirect_to :root, flash: {error: "You are not authorized to access any organization other than your own"}
        end
      end
  
  end