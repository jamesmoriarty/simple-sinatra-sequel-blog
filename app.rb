require "bundler/setup"

require "sinatra"
require "haml"
set :haml, {:ugly => true}

require 'rdiscount'

set :public_folder, 'public'
enable :method_override

require "sinatra/sequel"
set :database, ENV['DATABASE_URL']

require "./migrations"
class Article < Sequel::Model
  def before_save
    self.published_at ||= Time.now
    super
  end
end

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV["ADMIN_USERNAME"], ENV["ADMIN_PASSWORD"]]
  end
end

not_found do
  status 404
  haml :"404"
end

get "/" do
  @articles = Article.order(Sequel.desc(:published_at)).all
  haml :index, :locals => {:articles => @articles}
end

get "/new" do
  protected!
  haml :new
end

post "/" do
  protected!
  @article = Article.create(params[:article])
  redirect "/#{@article.id}"
end

get "/:id" do
  @article = Article[params[:id]] or raise Sinatra::NotFound
  haml :show, :locals => {:article => @article}
end

get "/:id/edit" do
  protected!
  @article = Article[params[:id]] or raise Sinatra::NotFound
  haml :edit, :locals => {:article => @article}
end

put "/:id" do
  protected!
  @article = Article[params[:id]] or raise Sinatra::NotFound
  @article.update(params[:article])
  redirect "/#{@article.id}"
end

delete "/:id" do
  protected!
  @article = Article[params[:id]] or raise Sinatra::NotFound
  @article.delete
  'ok'
end

__END__

@@ layout
%html
  %head
    %meta(charset="utf-8")
    %meta(name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1")
    %script(src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js")
    %link(href="/stylesheets/reset.css" rel="stylesheet" type="text/css")
    %link(href="/stylesheets/style.css" rel="stylesheet" type="text/css")
%body
  .header
    .left{:style => "float: left;"}
      %a(href="/")
        te·los
      &nbsp;-
      %i
        An ultimate object or aim.
    - if authorized?
      .right{:style => "float: right;"}
        %a{:href => "/new"}
          New
  .container
    = yield

@@ index
.articles
  - articles.each do |article|
    .article
      %h2.title
        %a{:href => "/#{article.id}"}
          = article.title
      .body
        = RDiscount.new(article.body).to_html
      - if article != articles.last
        %hr

@@ new
%form(action="/" method="post")
  .control-group
    %input(type="text" name="article[title]")
  .control-group
    %textarea(name="article[body]")
  .control-group
    %input(type="submit")

@@ show
.article
  - if authorized?
    .edit.title
      %a{:href => "/#{article.id}/edit"}
        Edit
  %h2.title
    = article.title
  .body
    = RDiscount.new(article.body).to_html

@@ edit
%form(action="/#{article.id}" method="post")
  %input(type="hidden" name="_method" value="put")
  .control-group
    %input{type: "text", name: "article[title]", value: article.title}
  .control-group
    %textarea{name: "article[body]"}
      = article.body
  .control-group
    %input(type="submit")
    %a(href="javascript:void(0)" class="js-delete" data-path="/#{article.id}")
      Delete

:javascript
  $(".js-delete").click(function(){
    $.ajax({
        url:      $(this).data("path"),
        type:     'DELETE',
        success:  function(data, textStatus) {
          window.location.href = "/";
        }
    });
  });

@@ 404
.error.title
  Nothing to see here...
