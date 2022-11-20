require 'open-uri'
require 'nokogiri'
require 'json'
require 'pry'
require_relative 'data'
require_relative 'car'

include ApplicationData

class Parser
	attr_reader :car_brand, :search_status, :amount

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
	end

	private

	def get_data_by_advertisement
		doc = html_response(set_url)
		doc.css('.content-bar').each_with_index do |car, index|
			return if index == amount
			parse_object(car)
		end
	end

	def get_data_by_pages
		amount.times do |page|
			page += 1
			doc = html_response(set_url + page.to_s) 
			doc.css('.content-bar').each do |car|
				parse_object(car)
			end	
		end
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
		car.print_object
	end

	def map_object(attribute)
		attribute.map { |tag| tag.text.strip}
	end

	def set_url
		if search_status == 2
			set_car_brand + PAGE_PART
		else
			set_car_brand
		end
	end

	def set_car_brand
		MAIN_LINK + car_brand
	end
end
