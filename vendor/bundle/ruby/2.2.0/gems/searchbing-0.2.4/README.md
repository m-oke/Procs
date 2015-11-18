searchbing [![Build Status](https://travis-ci.org/rcullito/searchbing.png?branch=master)](https://travis-ci.org/rcullito/searchbing) [![Gem Version](https://badge.fury.io/rb/searchbing.png)](http://badge.fury.io/rb/searchbing)
=========


![Puffin](http://photos-g.ak.fbcdn.net/hphotos-ak-snc1/hs166.snc1/6216_704615592619_7804626_41719230_39698_n.jpg)


A gem for the Bing Search API 2.0.
-------------
find the [gem](https://rubygems.org/gems/searchbing) on rubygems.org



## Installation
    gem install searchbing


Configuration
-------------
An account key is needed to use the Bing Search API. You can create a new account for the Bing Search API and obtain account key [here](http://www.bing.com/developers/)

## Usage

- valid search types include: Image, Web, News or Video. The first letter must be capitalized  

- this gem relies on the open-uri, net/http, and json gems.

Example: Interactive Ruby Shell
----------
require the gem in your shell session

   	require 'searchbing'
create a new search object, below 10 results are requested, you can retrieve up to 50 at a time

	bing_image = Bing.new('your_account_key_goes_here', 10, 'Image')
retrieve the results for a given term

	bing_results = bing_image.search("puffin")

or optionally specify an offset for your search, to start retrieving results from the starting point provided

    bing_results = bing_image.search("puffin", 25)

parse the results(recent changes require parsing with symbols, also please note the data structure of the response coming from bing has also changed)
 
    puts bing_results[0][:Image][0][:MediaUrl]

display the total number of results

    puts bing_results[0]["ImageTotal"]
