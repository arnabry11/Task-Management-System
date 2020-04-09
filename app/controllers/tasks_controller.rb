class TasksController < ApplicationController
  include TasksHelper
  before_action :authenticate_user!
  before_action :check_user_is_admin, only: [:approve]
  before_action :category_list, :employee_list, only: [:create, :edit, :update, :new]
  before_action :set_task, only: [:edit, :update, :show, :destroy, :submit_task, :approve]
  before_action :task_list

  def index
    @Tasks = Task.all
  end
  
  def task_list
    @priority = params[:priority]
    unless current_user.admin
      @Tasks_list =  current_user.tasks
      # Task.where(assign_task_to: current_user)
    else
      @Tasks_list =  Task.all
    end
  end

  def submit_task
    unless SubTask.all_subtasks_submitted(@task)
      flash[:warning] = "Please Complete Your Sub task to Complete this task"
      redirect_to task_path(@task)
      return
    end

    @task.submit = true
    @task.save
    flash[:notice] = "Your task submitted successfully"
    redirect_to tasks_path
  end
  def submit_subtask
    @subtask = SubTask.find(params[:id])
    @subtask.submit = true
    @subtask.save
    flash[:notice] = "You complete your Sub task " + @subtask.name
    redirect_to task_path(@subtask.task_id)
  end
  def approve
    session[:referer] = request.url
    unless @task.submit
      flash[:warning] = "Employee not Submitted the task yet."
      reditect_to session[:referer]
    end
    @task.approved = true
    @task.save(validate: false)
    flash[:success] = "Task Approved"
    redirect_to session[:referer]
  end

  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(task_params)
    @task.assign_task_by = current_user.id
    @task.submit_date = task_params[:submit_date].to_datetime
    unless task_params[:repeat] == "One Time"
      @task.recurring_task = true
    end
    if @task.save
      flash[:success]= I18n.t "task.success", taskname: @task.task_name, taskid: @task.id
      redirect_to tasks_path
    else
      flash[:danger] = I18n.t "task.faild"
      render "new"
    end
  end


  def edit
  end

  def update
    unless task_params[:repeat] == "One Time"
      @task.recurring_task = true unless @task.submit
    else
      @task.recurring_task = false
    end
    @task.submit_date = task_params[:submit_date].to_datetime

    if @task.update(task_params)
      flash[:success] = I18n.t "task.update_success", taskname: @task.task_name
      redirect_to task_path(@task)
    else
      flash[:danger] = I18n.t "task.failed"
      render "edit"
    end
  end

  def show
  end

  def destroy
    taskname= " id: "+@task.id.to_s + @task.task_name 
    @task.destroy
    flash[:notice] = I18n.t "task.destroy", task: taskname
    redirect_to tasks_path
  end

  private
  def category_list
    @categories ||= Category.all
  end
  def employee_list
    @users ||= User.all_except(current_user)
  end
  def task_params
    params.required(:task).permit(:task_category, :priority,:task_name, :description, :submit_date, :assign_task_to, :repeat, :document,sub_task_attributes: SubTask.attribute_names.map(&:to_sym).push(:_destroy))
  end
  def set_task 
    @task = Task.find(params[:id])
  end
  # def set_subtask
  #   @subtask =  SubTask.sub_tasks.find(params[:id])
  # end
end
