class Trade
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'awesome_print'

  attr_accessor :trade_id, :bid, :bin, :time_remaining, :seller, :my_bid, :offers_pending, :buy_it_now, :start_price, :card, :is_watched

  def self.create_from_watchlist(results)

    trades = []

    results.each do |result|
      t = Trade.new
      t.trade_id = result['tradeid'].to_i
      t.start_price = result['reserve'].to_i
      t.bid = result['highestbid'].to_i
      t.bin = result['credits'].to_i
      t.time_remaining = result['expiretime'].to_i
      t.seller = result['sellername']
      t.my_bid = !result['yourbidstate'].to_i.zero?
      t.offers_pending = result['offerspendingcount'].to_i
      t.is_watched = result["iswatched"] == "1" ? true : false
      t.buy_it_now = 1
      
      t.card = Card.create_from_carddata(result['carddata'])


      trades << t

    end

    trades
  end

  def self.create_from(results, search)

    trades = []

    results.each do |result|
      t = Trade.new
      t.trade_id = result['tradeid'].to_i
      t.start_price = result['reserve'].to_i
      t.bid = result['highestbid'].to_i
      t.bin = result['credits'].to_i
      t.time_remaining = result['expiretime'].to_i
      t.seller = result['sellername']
      t.my_bid = !result['yourbidstate'].to_i.zero?
      t.offers_pending = result['offerspendingcount'].to_i
      t.is_watched = result["iswatched"] == "1" ? true : false

      t.card = Card.create_from_carddata(result['carddata'])

      search.filters.each do |filter|
        if (t.bin <= filter.auto_buy_at && t.card.name.index(filter.name) && t.bin != 0)
          t.buy_it_now = t.buy_it_now || true
        else
          t.buy_it_now = t.buy_it_now || false
        end
      end

      t.buy_it_now = t.buy_it_now ? 0 : 1

      trades << t

    end

    trades
  end

end