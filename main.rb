# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :tarefas do
  primary_key :id
  String :nome
  String :url
  String :comissao
  Integer :pontos
end

DB.create_table :detalhes do
  primary_key :id
  String :nome
  String :url
  String :comissao
  String :local
  String :horario
  String :instrucao
  Integer :pontos
end

page = Nokogiri::HTML(open("http://www.equipeesparta.com.br/gincana/liberato/tarefas"))   

tarefas = DB[:tarefas]
page.css('#taskTable li').each do |t|
  tarefa = {
    :id => t['data-number'],
    :nome => t['data-title'],
    :pontos => t['data-points'].to_i,
    :comissao => t['data-type'].strip.downcase,
    :url => t.css('a')[0]['href']
  }
  puts tarefa.inspect
  tarefas.insert(tarefa)
end

puts "Foram encontradas #{tarefas.count} tarefas"
puts tarefas.all
