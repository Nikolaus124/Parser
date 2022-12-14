require 'csv'
require 'yaml'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'pry'


require 'rubygems'
require 'zip/zip'
require 'find'
require 'fileutils'

module MainApplication
  MAIN_LINK = 'https://auto.ria.com/uk/legkovie/'
  PAGE_PART = '/?page='

  class Car
    attr_reader :title, :price, :mileage, :location, 
				:fuel, :gear_type, :time

    def initialize(attributes)
      @title = attributes.fetch(:title, nil)
      @price = attributes.fetch(:price, nil)
      @mileage = attributes.fetch(:mileage, nil)
      @location = attributes.fetch(:location, nil)
      @fuel = attributes.fetch(:fuel, nil)
      @gear_type = attributes.fetch(:gear_type, nil)
      @time = attributes.fetch(:time, nil)
    end

	def map_car
		{
		  'Назва оголошення':	title,
      	  'Ціна': price,
      	  'Пробіг': mileage,
      	  'Локація': location,
      	  'Тип палива': fuel,
      	  'Коробка': gear_type,
      	  'Час створення оголошення': time
		}
	end
  end

  class Parser
	attr_reader :car_brand, :search_status, :amount

	RESULTS = []

	def initialize(car_brand, search_status, amount)
    	@car_brand = car_brand
    	@search_status = search_status
    	@amount = amount
  	end

	def run
		if search_status == 1
			get_data_by_advertisement
		elsif search_status == 2
			get_data_by_pages
		else
			puts 'Статус пошуку введено невірно'
		end	

		zip_files
	end

	private

	def get_data_by_advertisement
		doc = html_response(set_url)
		doc.css('.content-bar').each_with_index do |car, index|
			break if index == amount
			parse_object(car)
		end
		write_to_files
	end

	def get_data_by_pages
		amount.times do |page|
			page += 1
			doc = html_response(set_url + page.to_s) 
			doc.css('.content-bar').each do |car|
				parse_object(car)
			end	
		end
		write_to_files
	end

	def html_response(link)
		begin
  			html = open(link)
		rescue  
  			puts 'Не вірно введено марку авто!!!'
		end
		Nokogiri::HTML(html)
	end

	def parse_object(car)
		params = {}
		
		params[:title] = map_object(car.css('.head-ticket')).join(',')
		params[:price] = map_object(car.css('.price-ticket')).join(',')

		details = car.css('.definition-data, ul')
		if !details.empty?
			params[:mileage] = details.css('li')[0].text.strip
			params[:location] = details.css('li')[1].text.strip
			params[:fuel] = details.css('li')[2].text.strip
			params[:gear_type] = details.css('li')[3].text.strip
			params[:time] = map_object(car.css('.footer_ticket')).join(',')
		end
		car = Car.new(params)
		RESULTS << car.map_car
	end

	def map_object(attribute)
		attribute.map { |tag| tag.text.strip}
	end

	def set_url
		search_status == 2 ? set_car_brand + PAGE_PART : set_car_brand
	end

	def set_car_brand
		MAIN_LINK + car_brand
	end

	def write_to_files
		writer = Writer.new(RESULTS)
		writer.write_objects
	end

	def zip_files
		path = File.expand_path(File.dirname(__FILE__))
		File.delete('parser.zip') if File.exists? 'parser.zip'
		Zipper.zip(path, 'parser.zip')
	end
  end

  class Writer
	attr_reader :objects

	def initialize(objects)
    	@objects = objects
  	end

	def write_objects
		to_json
		to_csv
		to_yml
	end

	private

	def to_json
		remove_file('cars.json')
		File.open('results/cars.json', 'w+') { |f| f.puts objects.to_json }
	end

	def to_csv
		remove_file('cars.csv')
		column_names = objects.first.keys
		data = CSV.generate do |csv|
  			csv << column_names
  			objects.each do |x|
    			csv << x.values
  			end
		end
		File.write('results/cars.csv', data)
	end

	def to_yml
		remove_file('cars.yml')
		File.open('results/cars.yml', 'w+') {|f| f.puts objects.to_yaml }
	end

	def remove_file(file_name)
  		File.delete("results/#{file_name}") if File.exists? file_name
	end
  end

  class User
	attr_reader :login, :password

	def initialize(login, password)
      @login = login
      @password = password
	end
  end

  class Zipper
   def self.zip(dir, zip_dir, remove_after = false)
    Zip::ZipFile.open(zip_dir, Zip::ZipFile::CREATE)do |zipfile|
      Find.find(dir) do |path|
        Find.prune if File.basename(path)[0] == ?.
        dest = /#{dir}\/(\w.*)/.match(path)
        begin
          zipfile.add(dest[1],path) if dest
        rescue Zip::ZipEntryExistsError
        end
      end
    end
    FileUtils.rm_rf(dir) if remove_after
   end
  end
end
