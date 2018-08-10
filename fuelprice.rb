require 'httparty'
require 'json'

RACV_FUEL_PRICES_URL = 'https://www.racv.com.au/bin/racv/fuelprice.2.json'.freeze
IFTTT_TRIGGER_NAME = ENV['IFTTT_TRIGGER_NAME'].freeze
IFTTT_TRIGGER_KEY = ENV['IFTTT_TRIGGER_KEY'].freeze

response = HTTParty.get(RACV_FUEL_PRICES_URL, headers: {})

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

response = HTTParty.post(
  "http://maker.ifttt.com/trigger/#{IFTTT_TRIGGER_NAME}/with/key/#{IFTTT_TRIGGER_KEY}",
  body: {
    value1: prices_are.to_s,
    value2: dont_pay_above.to_s,
    value3: trend.to_s
  }.to_json,
  headers: {
    'Content-Type': "application/json"
  }
)

puts response.code, response.body
