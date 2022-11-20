require_relative 'parser'

puts 'Введіть марку авто латиницею:'
car_brand = gets.downcase.strip

puts 'Введіть 1 якщо бажаєте переглянути задану кількість оголошень,'
puts 'або ж 2, щоб переглянути оголошення на заданій кількості сторінок:'
search_status = gets.to_i

puts 'Введіть кількість:'
amount = gets.to_i

parser = Parser.new(car_brand, search_status, amount)
parser.run
