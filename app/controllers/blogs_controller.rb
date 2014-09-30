class BlogsController < ApplicationController

  def create
    blog            = Blog.new blog_params
    blog.project_id = params[:blog][:project_id]
    blog.user_id    = params[:blog][:user_id]

p "BlogsController>>create params=" + params.to_yaml
p "BlogsController>>create blog=" + blog.to_yaml
p "BlogsController>>create params[:blog][:project_id]" + params[:blog][:project_id].to_s
p "BlogsController>>create blog.project_id=" + blog.project_id.to_s
p "BlogsController>>create params[:blog][:user_id]=" + params[:blog][:user_id].to_s
p "BlogsController>>create blog.user_id=" + blog.user_id.to_s


    if blog.save
      render :json => blog
    else
      render :json => 'Project was not saved. Please check the input.'
    end
  end
  def blog_params
    params.require(:blog).permit(:text , :project_id , :user_id)
  end
end
