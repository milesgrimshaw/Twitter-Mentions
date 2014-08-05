# Load required gems
require 'oauth'
require 'json'
require 'csv'
require 'pp'
require 'YAML'
require 'date'

# Hash of dates for command line printing
DATES = {
  Date.today => 0,
  Date.today-1 => 0,
  Date.today-2 => 0,
  Date.today-3 => 0,
  Date.today-4 => 0,
  Date.today-5 => 0,
  Date.today-6 => 0,
  Date.today-7 => 0
}

def fullPath( relpath )
  File.expand_path( File.join(File.dirname(__FILE__), relpath) )
end

# Updates the count of mentions for each day in the dates hash
def update_dates ( date )
  date = Date.parse(date)
  if !DATES[date].nil?
    DATES[date] += 1
  end
end

# Prints out the date hash in a readible way
def print_dates ()
  for date in DATES
    pp "#{date[1]} Tweets On #{date[0].strftime("%Y-%m-%d")}"
  end
end

##  main logic loop
def main( token = '' )

  # open file to dump data into
  ff = CSV.open(fullPath('/data/'+ token + '.csv'), 'a')

  # authenticate
  auth = authenticate()

  # local loop var
  max_id = nil

  # Retry Loop just to make sure not a failed call
  retries = 0

  # loop over paginated twitter results
  begin
    pp 'mining page'
    addr = buildAddress(token, max_id)

    resp = grabResults(addr, auth)
    tweets = parseResults(resp)

    # first time through, dump headers
    if max_id == nil
      ff << tweets[0].keys || []
    end

    # else just dump each row
    tweets.each do |t|

      # increment date counter
      date = t["created_at"]
      update_dates (date)
      
      ff << [t["created_at"], t["id"], t["id_str"], t["text"], t["user"],t["retweeted_status"], t["retweet_count"], t["fav_count"],t["entities"], t["favorited"], t["retweeted"]]
    
    end

    num = tweets.length
    pp "The number of tweets is: #{num}"

    # and increment
    if (max_id == nil) & (retries < 3) & (num <= 1)
      num = num + 1
      retries = retries + 1
    elsif (max_id == nil)
      max_id = tweets[(num-1)]["id"]
    elsif (num>1) & (retries < 3)
      max_id = tweets[(num-1)]["id"]
    elsif (num==1) & (retries < 3)
      max_id = tweets[(num-1)]["id"]
      num = 2
      retries = retries + 1
    elsif (num==0) & (retries < 3)
      max_id = max_id -1
      retries = retries + 1
      num = 2
    end

  end while num > 1

  # close shop
  ff.close

  print_dates()

end


## authenticate w/ OAUTH
def authenticate()

  twitter_config = YAML.load_file(fullPath('/twitter.yml' ))
  credentials = twitter_config["credentials"]

  ckey = OAuth::Consumer.new(
		credentials["consumer_key"],
		credentials["consumer_secret"])

	atok = OAuth::Token.new(
		credentials["access_token"],
	  credentials["access_secret"])

	return {:ckey => ckey, :atok => atok }
end

## build URL to query for next request
def buildAddress(token, max_id)

  # query object, holds query params
  ## Changed to 90 b/c 100 seemed to cause some problems
  q_obj = {
    'q' => token,
    'result_type' => 'recent',
    'count' => 100
  }
  q_obj['max_id'] = max_id if max_id
  # q_obj['count'] = 100

  # construct address from base and encoded query
  base = 'https://api.twitter.com/1.1/search/tweets.json'
  address = URI( base + '?' +  URI.encode_www_form(q_obj)  )

  return address
end


## grab the URL and pull down a response
def grabResults(address, auth)
  request = Net::HTTP::Get.new address.request_uri

  # Set up Net::HTTP to use SSL, which is required by Twitter.
  http = Net::HTTP.new address.host, address.port
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # # Issue the request.
  request.oauth! http, auth[:ckey], auth[:atok]
  response = http.request request

  ## Check to see if exceeded API limit
  while response.code == '429'

    pp 'rate limited, waiting 5min'
  	sleep 5*60
  	response = grabResults(address, auth)
  end

  return response
end


## parse JSON results into our tweets array
def parseResults( resp )
  data = JSON.parse(resp.body)
	return data['statuses']
end

def extract_data( t )
  return [t["created_at"], t["id"], t["id_str"], t["text"], t["user"],t["retweeted_status"], t["retweet_count"], t["fav_count"],t["entities"], t["favorited"], t["retweeted"]]
end


# call it
main(ARGV[0])