# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler'

Bundler.require

desc "импорт данных из csv"
task :import do
  require './app'
  require 'csv'
  require 'open-uri'
  
  CSV.parse(open('https://docs.google.com/spreadsheet/pub?key=0Au0stnPml5jIdHhSZl9NQTdtMHpqdWFCYk9SWm55cXc&single=true&gid=0&output=csv').read, headers: true) do |row|
    brand_hash = {
      title: row[0],
      translit: row[1],
      country: row[2],
      year: row[3],
      founder: row[4],
      ceo: row[5],
      site: row[7],
      page_title: row[8],
      meta_description: row[9],
      meta_keywords: row[10],
      slug: Russian::translit(row[0]).downcase.gsub(/\s/,'-')
    }
    
    brand_hash[:desc] = row[11].gsub(/CATALOG_URL/,"/catalog-#{brand_hash[:slug]}")

    brand = Brand.create(brand_hash)
    
    puts "Бренд: #{brand.title}"
    
    row[6].split(',').map(&:strip).map do |title|
      if category = Category.first(title: title)
        category
      else
        Category.create(title: title, slug: Russian::translit(title).downcase.gsub(/\s/,'-'))
      end
    end.each do |category|
      Categorization.create(brand: brand, category: category)
    end
    
    if row[12]
      catalog_hash = {
        page_title: row[12],      
        meta_description: row[13],
        meta_keywords: row[14],
        title: row[15],
        text: row[16],
        brand: brand
      }
      catalog = Catalog.create(catalog_hash)
      puts "Каталог Бренда: #{catalog.title}"
    end
  end
end

desc "очистка базы"
task :clean do
  require './app'
  puts "Clean brands: #{Brand.count}"
  Brand.destroy
  puts "Clean categories: #{Category.count}"  
  Category.destroy
  puts "Clean HBTM table: #{Categorization.count}"  
  Categorization.destroy
  puts "Clean catalogs: #{Catalog.count}"
  Catalog.destroy
end
