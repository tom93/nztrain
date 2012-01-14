class ProblemsController < ApplicationController
  before_filter :check_signed_in
  before_filter :check_access, :only => [:show, :edit]
  before_filter :check_admin, :only => [:new, :edit, :create, :destroy, :update]

  def check_access
    prob = Problem.find(params[:id])
    
    if !prob.can_be_viewed_by(current_user)
      redirect_to(problems_path, :alert => "You do not have access to this problem!")
    end
  end

  # GET /problems
  # GET /problems.xml
  def index

    @problems = Problem.select("problems.*, MAX(submissions.score) as score").joins("LEFT OUTER JOIN submissions ON submissions.problem_id = problems.id AND submissions.user_id = #{current_user.id}").group("problems.id")
    @problems = @problems.find_all {|p| p.can_be_viewed_by(current_user) }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @problems }
    end
  end

  # GET /problems/1
  # GET /problems/1.xml
  def show
    @problem = Problem.find(params[:id])
    @submission = Submission.new
    #TODO: restrict to problems that current user owns
    @contests = Contest.all
    @groups = Group.all
    @submissions = @problem.submission_history(current_user)
    @all_subs = {};
    @problem.submissions.each do |sub|
    	@all_subs[sub.user] = [(@all_subs[sub.user] or sub), sub].max_by {|m| m.score}
    end
    @all_subs = @all_subs.map {|s| s[1]}

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @problem }
    end
  end

  # GET /problems/new
  # GET /problems/new.xml
  def new
    @problem = Problem.new
    @problem.user_id = current_user.id
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @problem }
    end
  end

  # GET /problems/1/edit
  def edit
    @problem = Problem.find(params[:id])
  end

  # POST /problems
  # POST /problems.xml
  def create
    @problem = Problem.new(params[:problem])
    if @problem.evaluator != nil
      @problem.evaluator = IO.read(params[:problem][:evaluator].path)
    end

    respond_to do |format|
      if @problem.save
        format.html { redirect_to(@problem, :notice => 'Problem was successfully created.') }
        format.xml  { render :xml => @problem, :status => :created, :location => @problem }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @problem.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /problems/1
  # PUT /problems/1.xml
  def update
    @problem = Problem.find(params[:id])
    if params[:problem][:evaluator] != nil
      params[:problem][:evaluator] = IO.read(params[:problem][:evaluator].path)
    end

    respond_to do |format|
      if @problem.update_attributes(params[:problem])
        format.html { redirect_to(@problem, :notice => 'Problem was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @problem.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /problems/1
  # DELETE /problems/1.xml
  def destroy
    @problem = Problem.find(params[:id])
    @problem.destroy

    respond_to do |format|
      format.html { redirect_to(problems_url) }
      format.xml  { head :ok }
    end
  end
end
