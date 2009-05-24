#!/usr/bin/env ruby

require 'rubygems'
require 'activesupport'
require 'rest_client'
require 'pp'

# These are the same credentials used to register with the Drone Interface.
username = "username"
password = "password"

BASE_URL = 'https://' + username + ':' + password + '@127.0.0.1'

# To submit a job programmatically, use the following example.  By default, the
# job will be marked as originating from you, based upon your login credentials.
# Furthermore, when the job is complete, you will be notified using the email
# address associated with your login.
payload = {
  :input => {
    # All URLs for the job are specified in a single key/value pair, where the URLs are separated by
    # whitespace.  Note: If the URL itself contains whitespace, then this data must be URL-encoded (e.g., %20)
    :urls => 'http://www.google.com/ http://www.cnn.com/',

    # When created, all URLs will have the following specified priority.  If you want different priorities per
    # URL, then create separate jobs accordingly.  The higher the number, the more likely this job will get
    # processed ahead of all others.
    :priority => 600
  }
}
result = RestClient.post BASE_URL + '/jobs.json', payload.to_json, :format => 'json', :content_type => 'application/json'
hash = ActiveSupport::JSON.decode(result)
pp hash

# If you want to record a different source from where the URLs are coming from, you can specify this
# programmatically, as follows.  You will still be notified using your same email address.
payload = {
  :input => {
    # All URLs for the job are specified in a single key/value pair, where the URLs are separated by
    # whitespace.  Note: If the URL itself contains whitespace, then this data must be URL-encoded (e.g., %20)
    :urls => 'http://www.craigslist.org/ http://www.woot.com/',

    # When created, all URLs will have the following specified priority.  If you want different priorities per
    # URL, then create separate jobs accordingly.  The higher the number, the more likely this job will get
    # processed ahead of all others.
    :priority => 600,

    :job_source => {
        :name     => 'Other URL Source',
        :protocol => 'https',
    }
  }
}
result = RestClient.post BASE_URL + '/jobs.json', payload.to_json, :format => 'json', :content_type => 'application/json'
hash = ActiveSupport::JSON.decode(result)
pp hash

# After successfully submitting a job, this is an example of the type of data returned:
#{"job"=>
#  {"completed_at"=>nil,
#   "job_source_id"=>21,
#   "updated_at"=>nil,
#   "client_id"=>nil,
#   "uuid"=>"f29625ba-5d3c-047e-463d-0ae4fad0a22a",
#   "url_count"=>2,
#   "created_at"=>Wed May 20 03:58:55 UTC 2009}}

# Specifically, the service indicates how many URLs were successfully parsed, via hash["job"]["url_count"].
# Additionally, the service provides a unique Job UUID, via hash["job"]["uuid"].  You can then
# use this UUID to query the status of this job, at any given time.

sleep 10

# Here is an example of this query:

result = RestClient.get BASE_URL + '/jobs/list.json?uuid=' + hash["job"]["uuid"], :format => 'json', :content_type => 'application/json'
array = ActiveSupport::JSON.decode(result)
pp array

# Here is the example output:
#[{"job"=>
#   {"completed_at"=>nil,
#    "job_source_id"=>22,
#    "updated_at"=>Wed May 20 04:03:13 UTC 2009,
#    "client_id"=>18946,
#    "id"=>1792,
#    "uuid"=>"d2ea0bb8-5d77-cda8-111b-7e9a04c83c02",
#    "url_count"=>2,
#    "created_at"=>Wed May 20 04:03:11 UTC 2009}}]

# In general, the job is not considred complete until the 'completed_at' field has a similar date/timestamp as 'created_at'.

# In order to check the status of individual URLs associated with this job, you then use the job ID (not UUID) and
# construct the following query:

result = RestClient.get BASE_URL + '/urls/list.json?job_id=' + array[0]["job"]["id"].to_s, :format => 'json', :content_type => 'application/json'
array = ActiveSupport::JSON.decode(result)
pp array

# Here is the example output:

#[{"url"=>
#   {"job_id"=>1806,
#    "updated_at"=>Wed May 20 04:44:50 UTC 2009,
#    "url_status_id"=>1,
#    "client_id"=>nil,
#    "fingerprint_id"=>nil,
#    "priority"=>600,
#    "url"=>"http://www.craigslist.org/",
#    "id"=>57381,
#    "time_at"=>nil,
#    "created_at"=>Wed May 20 04:44:49 UTC 2009}},
# {"url"=>
#   {"job_id"=>1806,
#    "updated_at"=>Wed May 20 04:44:50 UTC 2009,
#    "url_status_id"=>1,
#    "client_id"=>nil,
#    "fingerprint_id"=>nil,
#    "priority"=>600,
#    "url"=>"http://www.woot.com/",
#    "id"=>57382,
#    "time_at"=>nil,
#    "created_at"=>Wed May 20 04:44:49 UTC 2009}}]

# In general, when a URL has been visited, the URLs 'time_at' field will be populated with a timestamp in the form of
# number of microseconds since the epoch (e.g., 1203966522.974900).  Note that this is a *different* timestamp format
# than 'created_at' and 'updated_at'.

# Additionally, in order to figure out if the URL has been visited (with no suspicious activity) or if it has been
# found to be suspicious, you check the URLs 'url_status_id'.  You can get a human-readable version of this ID,
# by constructing the following query:

result = RestClient.get BASE_URL + '/url_statuses/' + array[0]["url"]["url_status_id"].to_s + '.json', :format => 'json', :content_type => 'application/json'
hash = ActiveSupport::JSON.decode(result)
pp hash

# Here is the example output:

#{"url_status"=>
#  {"status"=>"queued",
#   "id"=>1,
#   "description"=>"URL is queued for processing."}}

# If the URL were flagged as suspicious, this would be the example output:

#{"url_status"=>
#  {"status"=>"suspicious",
#   "id"=>3,
#   "description"=>"URL was visited and appears to contain malicious activity."}}

