require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra'
require 'build_man'
require 'json'

context = BuildMan::DataContext.new

get '/projects' do
  context.get_projects.to_json
end

get '/projects_with_most_recent_result' do
  context.get_projects_with_most_recent_result.to_json
end

put '/project' do
  context.insert_project(params[:name])
end

put '/project_build_result' do
  context.insert_project_build_result(
    params[:id], 
    params[:is_success], 
    params[:build_data], 
    params[:message], 
    params[:data])
end