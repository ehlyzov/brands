# -*- coding: utf-8 -*-
require 'sinatra'
require 'slim'
require 'dm-core'
require 'dm-migrations'
require 'unicode'

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
# TODO: Add database models here.

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

get '/:s' do |slug|
  if brand = Brand.get(slug)  
    slim :brand, locals: {
      brand: brand,
      categories: Category.all,
      title: "#{brand.title}<small> / #{brand.translit}</small>"
    }
  elsif category = Category.get(slug)
    slim :category, locals: {
      category: category,
      title: Unicode::capitalize(category.title)
    }
  else
    404
  end
end


