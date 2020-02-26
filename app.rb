require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "758690cc3b7af71afc5d67399123641b"

# enter news API key
url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=55e4f07f06bf424a8005fa6ea78ed063"

get "/" do
  # show a view that asks for the location
view "ask"
end

get "/news" do
    # Gets City Name
    @results = Geocoder.search(params["location"])
    @lat_long = @results.first.coordinates # => [lat, long]
    @lat = "#{@lat_long[0]}" 
    @long = "#{@lat_long[1]}"
    @city_name = params["location"]

    # Get Weather based on City Name
    @forecast = ForecastIO.forecast("#{@lat}","#{@long}").to_hash
    @current_summary = @forecast["currently"]["summary"]
    @current_temp = @forecast["currently"]["temperature"]
    @week_high = @forecast["daily"]["data"]

    # Create Array of Forecasts
    @weather_array = []
    i = 1

    for daily in @week_high
        @weather_array << "Day #{i}: A high temperature of #{daily["temperatureHigh"].round(0)} degrees fahrenheit and #{daily["summary"].downcase}"
        i = i + 1
    end

    # puts @weather_array
    
    @news = HTTParty.get(url).parsed_response.to_hash
    # news is now a Hash you can pretty print (pp) and parse for your output

    @article_array = []
    j = 0 # article number
    @url_array = []
   
    for newsly in @news["articles"]
        @article_array << @news["articles"][j]["title"]
        @url_array << @news["articles"][j]["url.truncate(3)"]
        j = j + 1
    end

    puts @article_array

    view "news"

    
end