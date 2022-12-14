require_relative 'main_application'
require_relative 'send_mail'
require 'io/console'
require 'pry'
extend MainApplication

puts 'Введіть марку авто латиницею:'
car_brand = gets.downcase.strip

while true
	puts 'Введіть 1 якщо бажаєте переглянути задану кількість оголошень,'
	puts 'або ж 2, щоб переглянути оголошення на заданій кількості сторінок:'
	search_status = gets.to_i
	break if search_status.between?(1,2)
	puts 'Задане число не задовільняє умову'
end

while true
	puts 'Введіть кількість:'
	amount = gets.to_i
	break if amount.between?(1,20)
	puts 'Задане число не задовільняє умову'
end
parser = MainApplication::Parser.new(car_brand, search_status, amount)
parser.run


puts 'Надіслати вам листа з архівом проекта?(yes/no):'
flag = gets.strip

if flag == 'yes'
	puts "Ваша електронна адреса:"
	my_mail = STDIN.gets.chomp

	puts "Ваш пароль до пошти #{my_mail} для відправки листа:"
	password = STDIN.noecho(&:gets).chomp

	user = MainApplication::User.new(my_mail, password)

	puts "Кому відправити листа:"
	send_to = STDIN.gets.chomp

	puts "У вас є якийсь коментар до архіву?"
	message = STDIN.gets.chomp.encode("UTF-8")

	mailer = SendMail.new(user, send_to, message)
	mailer.send_mail
end