require 'csv'

class Writer
	attr_reader :objects

	def initialize(objects)
    	@objects = objects
  	end

	def write_objects
		to_json
		to_csv
	end

	private

	def to_json
		remove_file('cars.json')
		File.open('cars.json', 'w+') { |f| f.puts objects.to_json }
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
		File.write('cars.csv', data)
	end

	def remove_file(file_name)
  		File.delete(file_name) if File.exists? file_name
	end
end
