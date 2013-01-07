# -*- coding: utf-8 -*-
require 'sinatra'
require 'slim'
require 'dm-core'
require 'dm-migrations'
require 'unicode'
require 'rake'



configure do
  set :public_folder, Proc.new { File.join(root, "bootstrap") }
end

class Object
    def present?
      !blank?
    end

    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end
  
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/my.db")
  DataMapper::Property::String.length(255)


class Catalog
  include DataMapper::Resource
  
  belongs_to :brand
  property :id, Serial
  property :page_title, String
  property :title, String
  property :meta_description, Text
  property :meta_keywords, Text
  property :text, Text
end
  
class Brand
  include DataMapper::Resource

  property :title, String

  property :page_title, String
  property :meta_description, Text
  property :meta_keywords, Text
  
  property :translit, String
  property :slug, String, key: true
  property :country, String
  property :year, Integer
  property :founder, String
  property :ceo, String
  property :site, String

  property :desc, Text
  
  has n, :categorizations  
  has n, :categories, through: :categorizations

  has 1, :catalog
end

class Category
  include DataMapper::Resource
  
  property :slug, String, key: true
  property :title, String
  
  has n, :categorizations
  has n, :brands, through: :categorizations
end

class Categorization
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :category
  belongs_to :brand
end

DataMapper.finalize
DataMapper.auto_upgrade!

Categories = ['obuv'].freeze

helpers do
  def link_to_category(category)
    %{<a href="/#{category.slug}">#{category.title}</a>}
  end
end

not_found do
  slim :'404', layout: false
end

get '/' do
  slim :home, locals: {
    brands: Brand.all,
    title: "Каталог Брендов"
  }
end

get '/updatedb' do
  unless Rake::Task.task_defined?('import')
    load File.expand_path(File.dirname(__FILE__) + '/Rakefile')
  end
  
  Rake::Task['clean'].invoke
  Rake::Task['import'].invoke
  
  Rake::Task['clean'].reenable
  Rake::Task['import'].reenable
  slim "<pre>ok</pre>", layout: false
end

get '/catalog-:s' do |slug|
  brand = Brand.get(slug)
  catalog = brand.catalog
  slim '== text', locals: {
    text: catalog.text,
    title: catalog.title,
    meta_description: catalog.meta_description,
    meta_keywords: catalog.meta_keywords,
    page_title: catalog.page_title
  }
end

get '/:s' do |slug|
  if brand = Brand.get(slug)  
    slim :brand, locals: {
      brand: brand,
      title: "#{brand.title}<small> / #{brand.translit}</small>",
      page_title: brand.page_title,
      meta_description: brand.meta_description,
      meta_keywords: brand.meta_keywords      
    }
  elsif category = Category.get(slug)
    slim :category, locals: {
      category: category,
      title: Unicode::capitalize(category.title),
    }
  else
    404
  end
end


