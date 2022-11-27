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

   	def print_car
   		puts title 
		puts price
		puts mileage
		puts location
		puts fuel
		puts gear_type
		puts time
		puts '----------------------------------------'
	end

	def attrs
    	instance_variables.map{|ivar| instance_variable_get ivar}
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