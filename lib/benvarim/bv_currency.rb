# -*- coding: utf-8 -*-
class BvCurrency
  @@DEFAULT_CONVERSIONS = {
    "USD" =>  {
      "TRY" => 1.79
    },
    "EUR" => {
      "TRY" => 2.44
    }
  }
  #returns nil if cant find!
  def self.convert(from, to)
    if from == to
      return 1
    end
    #http://download.finance.yahoo.com/d/quotes.csv?s=USDTRY=X&f=l1
    require 'net/http'

    require 'rubygems'

    require 'xmlsimple'

    url = 'http://download.finance.yahoo.com/d/quotes.csv?s=' + from + to + '=X&f=l1'

    begin
      data = Net::HTTP.get_response(URI.parse(url)).body
      d = data.to_f
      if(data && d != 0)
        self.cache_result(from, to, d)
        return d
      end
    rescue
      #try to read from cache
      cached = self.read_from_cache(from, to)
      if(cached)
        return cached
      else
        #check default values, if presents, use them
        rate = @@DEFAULT_CONVERSIONS[from] && @@DEFAULT_CONVERSIONS[from][to];
        #may return nil
        return rate
      end
    end
  end
  def self.cache_key (from, to)
    "currency-" + from + "-" + to
  end

  def self.cache_result (from, to, rate)
    Rails.cache.write(self.cache_key(from, to), rate)
  end

  def self.read_from_cache (from, to)
    Rails.cache.read(self.cache_key(from, to))
  end

  def self.human_readable_currency(type)
    case type
      when "TRY"
        "TL"
      when "USD"
        "$ (ABD)"
      when "EUR"
        "€ (avro)"
      else
        type
    end
  end
end