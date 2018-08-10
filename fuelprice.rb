require 'net/http'
require 'uri'
require 'json'

RACV_FUEL_PRICES_URL = 'https://www.racv.com.au/bin/racv/fuelprice.2.json'.freeze
IFTTT_TRIGGER_NAME = ENV['IFTTT_TRIGGER_NAME'].freeze
IFTTT_TRIGGER_KEY = ENV['IFTTT_TRIGGER_KEY'].freeze

racv_uri = URI.parse(RACV_FUEL_PRICES_URL)
response = JSON.parse(Net::HTTP.get(racv_uri))

todays_avg_price = response['TodaysPrice']['CustomRegionsAvgHighLow'].last['AvgPrice'].to_f
yesterdays_avg_price = response['YesterdaysPrice']['CustomRegionsAvgHighLow'].last['AvgPrice'].to_f
wholesale_price = response['WholesaleTodayAveragePrice'].to_i
delta = todays_avg_price.to_i - wholesale_price

dont_pay_above = response['DontBuyMoreThan']['CustomRegion25PercentilePrices'].last['Price'].to_f
prices_are = [
  'low',
  'OK',
  'high'
][delta >= 10 ? 2 : (delta >= 4 ? 1 : 0)]
trend = [
  'lower',
  'higher'
][(todays_avg_price > yesterdays_avg_price) ? 1 : 0]

ifttt_uri = URI.parse("http://maker.ifttt.com/trigger/#{IFTTT_TRIGGER_NAME}/with/key/#{IFTTT_TRIGGER_KEY}")
request = Net::HTTP::Post.new(ifttt_uri)
request.content_type = "application/json"
request.body = JSON.dump({
  value1: prices_are.to_s,
  value2: dont_pay_above.to_s,
  value3: trend.to_s
})

req_options = {
  use_ssl: ifttt_uri.scheme == "https",
}

response = Net::HTTP.start(ifttt_uri.hostname, ifttt_uri.port, req_options) do |http|
  http.request(request)
end

puts response.code, response.body
