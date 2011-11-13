class StockController < ApplicationController

require 'rubygems'
require 'json'
require 'net/http'
require 'uri'
require 'nexmo'    
    
def lookup
	symbol = params[:Symbol]
     	symbol.upcase.gsub!(/![A-Z]/, "")
     
        stockQuoteResponse = Hash.new;
        stocksResults = get_quote(symbol);
        stockQuoteResponse["Symbol"] = stocksResults["query"]["results"]["quote"]["symbol"];
        stockQuoteResponse["Ask"] = stocksResults["query"]["results"]["quote"]["Ask"];
	stockQuoteResponse["Bid"] = stocksResults["query"]["results"]["quote"]["Bid"];          	
	stockQuoteResponse["Name"] = stocksResults["query"]["results"]["quote"]["Name"];
          
	@Stocks = stockQuoteResponse;
	
	if stockQuoteResponse["Ask"] != nil
        	          
        	smsno = String.new;
        	smsno = params[:SMSno]
          
        	if(smsno =~ /^\+[1-9]{1}[0-9]{7,11}$/)  	
			message = stockQuoteResponse["Name"] + " (" + stockQuoteResponse["Symbol"] + ") " + "Ask Price: " + 				stockQuoteResponse["Ask"] + " Bid Price: " + stockQuoteResponse["Bid"]
          	
          		smsend = true;
          		smsend = sendtext(smsno,message)
          	
          		stockQuoteResponse["sms"] = smsno.to_str;
        	else
        		stockQuoteResponse["sms"] = ""
        	end
	else
		puts "Sorry - we can't seem to find this stock - please try again"
	end

end

def get_quote(squote)
	url = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%3D%22#{ squote }%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
	response = Net::HTTP.get_response(URI.parse(url))
	
        result = JSON.parse(response.body)
        
	return result
end
     
def sendtext(smsno,message)
	smsno = smsno.gsub!(/\D/, "") 

	nexmoinit = Nexmo::Client.new('1a2c82c2','48ccff35')

	#result = nexmoinit.send_message({'from' => '46769436051','to' => smsnumber,'text' => message })
	result = nexmoinit.send_message({'from' => 'Stock Quote System','to' => smsno,'text' => message })

     	return result
end

end



