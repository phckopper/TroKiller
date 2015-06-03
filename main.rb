# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'twilio-ruby'
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

@client = Twilio::REST::Client.new 'ACa0541b603fff961e566bac3a8a8c70bf', 'e0fa189b4db8c80ffc42af96fe65f52d'

scheduler.every '10s' do
  page = Nokogiri::HTML(open("http://www.equipeesparta.com.br/gincana/liberato/tarefas"))   
  
  passados = File.read("passados.txt").split(",").map(&:to_i)

  page.css('#taskTable li').each do |t|
    tarefa = {                                     #Deixei tudo criado pra se formos usar outros dados depois
      :id => t['data-number'],
      :nome => t['data-title'],
      :pontos => t['data-points'].to_i,
      :comissao => t['data-type'].strip.downcase,
      :url => t.css('a')[0]['href']
    }
    puts tarefa.inspect
    @client.messages.create(
      from: '+12485563453',
      to: ['+555192403954', '+555197103701'],
      body: "NOVA TAREFA: " << tarefa[:nome] << " " << tarefa[:url]
    ) unless passados.include? tarefa[:id].to_i
    File.open('passados.txt', 'a') do |f|
      f << tarefa[:id].to_i.to_s << ","
    end unless passados.include? tarefa[:id].to_i
  end
end

scheduler.join #faz o script nao terminar imediatamente
