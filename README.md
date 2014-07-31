## How To Use

### Set Up
1.	Get Twitter OAUTH tokens from the Twitter developer site
1. 	Create a `twitter.yml` file and add the credentials
3.	Make sure you have all the required ruby gems installed by running `bundle install`

### Data Output
1. Run `ruby twitter.rb search_term`

It is only set up to run for a singular search term, and will print out the daily count for that term

### Graph Output
1. 	Run `bash twitter.sh <search-term> <search-term> ...` with as many terms as you want

## Goal

I built this basic set of files to be able to quickly generate a graphic comparing the number of tweets that included specific terms or companies' handles. I then made it a simple bash script using a ruby script to get tweets from Twitter and an R Script to visualize. 

## Limitations

Twitter only gives you API access to the last 7 days of tweets. The next step is to make this run daily with a given set of terms. 