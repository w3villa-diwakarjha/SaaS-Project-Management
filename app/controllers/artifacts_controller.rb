class ArtifactsController<ApplicationController
    before_action :set_artifact, only: %i[show edit update destroy]

    def index
        @artifacts=Artifact.all

    end
    
    def show
    end


    def new 
        @artifact=Artifact.new
        @artifact.project_id=params[:project_id]
    end

    def edit
    end

    def create
        @artifact= Artifact.new(artifact_params)

        respond_to do |format|
            if @artifact.save
            format.html {redirect_to tenant_project_url(tenant_id: current_tenant.id, id: @artifact.project_id), notice:  "Artifact was Successfully Created"}
            format.json {render :show, status: :created, location: @artifact}
            else
                format.html {render :new, status: :unprocessable_entity}
                format.json {render json: @artifact.errors, status: :unprocessable_entity}
            end
        end

    end

    def update

        respond_to do |format|  
            if @artifact.update(artifact_parmas)
                format.html {redirect_to artifact_url(@artifact), notice: "Artifact was successfully updated"}
                format.json { render :show, status: :ok, location: @artifact }
            else
                format.html { render :edit, status: :unprocessable_entity }
                format.json { render json: @artifact.errors, status: :unprocessable_entity }
            end
        end
    end

  def destroy
    @artifact.destroy

    respond_to do |format|
      format.html { redirect_to tenant_project_url(tenant_id: current_tenant.id, id: @artifact.project_id), notice: "Artifact was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_artifact
      @artifact = Artifact.find(params[:id])
    end

    def artifact_params
      params.require(:artifact).permit(:name, :upload, :project_id)
    end

end