# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler'

Bundler.require

desc "импорт данных из csv"
task :import do
  require './app'
  require 'csv'
  CSV.foreach('./data.csv', headers: true) do |row|
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
      desc: row[11],
      slug: Russian::translit(row[0])
    }
    brand = Brand.create(brand_hash)
    
    puts "Бренд: #{brand.title}"
    
    row[6].split(',').map(&:strip).map do |title|
      if category = Category.first(title: title)
        category
      else
        Category.create(title: title, slug: Russian::translit(title))
      end
    end.each do |category|
      Categorization.create(brand: brand, category: category)
    end

    catalog_hash = {
      page_title: row[12],      
      meta_description: row[13],
      meta_keywords: row[14],
      title: row[15],
      text: row[16],
      brand: brand
    }

    if catalog_hash[:title]
      catalog = Catalog.create(catalog_hash)
      puts "Каталог Бренда: #{catalog_hash}"
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
