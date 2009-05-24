#!/usr/bin/perl -w

use warnings;
use strict;

use Data::Dumper;
use REST::Client;
use JSON::XS qw(encode_json decode_json);

# These are the same credentials used to register with the Drone Interface.
my $username = 'username';
my $password = 'password';

my $client = REST::Client->new({
    host => 'https://' . $username . ':' . $password . '@127.0.0.1'
});

my $response = undef;

# To submit a job programmatically, use the following example.  By default, the job will be marked
# as originating from you, based upon your login credentials.  Furthermore, when the job is complete,
# you will be notified using the email address associated with your login.
my $input = {
    'input' => {
        # All URLs for the job are specified in a single key/value pair, where the URLs are separated by whitespace.
        # Note: If the URL itself contains whitespace, then this data must be URL-encoded (e.g., %20)
        'urls'     => "http://www.google.com/ http://www.cnn.com/",

        # When created, all URLs will have the following specified priority.  If you want different
        # priorities per URL, then create separate jobs accordingly.  The higher the number, the more likely
        # this job will get processed ahead of all others.
        'priority' => 10,
    },
};
$client->request('POST', '/jobs.json', encode_json($input), {'Content-Type' => 'application/json'});
$response = decode_json($client->responseContent());
print Dumper($response) . "\n";

# If you want to record a different source from where the URLs are coming from, you can specify this
# programmatically, as follows.  You will still be notified using your same email address.
$input = {
    'input' => {
        'urls'     => "http://www.craigslist.org/ http://www.woot.com/",
        'priority' => 10,
        'job_source' => {
            'name'     => 'Other URL Source',
            'protocol' => 'https',
        },
    },
};
$client->request('POST', '/jobs.json', encode_json($input), {'Content-Type' => 'application/json'});
$response = decode_json($client->responseContent());
print Dumper($response) . "\n";

# After successfully submitting a job, this is an example of the type of data returned:
#$VAR1 = {
#          'job' => {
#                     'url_count' => 2,
#                     'created_at' => '2009-05-12T19:14:54Z',
#                     'job_source_id' => 19,
#                     'updated_at' => undef,
#                     'client_id' => undef,
#                     'uuid' => 'e334d846-3c8e-815c-12ab-f8b6b32cdaad',
#                     'completed_at' => undef
#                   }
#        };

# Specifically, the service indicates how many URLs were successfully parsed, via $response->{'job'}->{'url_count'}.
# Additionally, the service provides a unique Job UUID, via $response->{'job'}->{'uuid'}.  You can then
# use this UUID to query the status of this job, at any given time.

sleep(10);

# Here is an example of this query:

$client->request('GET', '/jobs/list.json?uuid=' . $response->{'job'}->{'uuid'});
$response = decode_json($client->responseContent());
print Dumper($response) . "\n";

# Here is the example output:
#$VAR1 = [
#          {
#            'job' => {
#                       'job_source_id' => 20,
#                       'client_id' => undef,
#                       'uuid' => '86585843-75b3-2e86-04b7-3b85b1fb2208',
#                       'url_count' => 2,
#                       'created_at' => '2009-05-12T19:18:55Z',
#                       'updated_at' => '2009-05-12T19:18:56Z',
#                       'id' => 1176,
#                       'completed_at' => undef
#                     }
#          }
#        ];

# In general, the job is not considred complete until the 'completed_at' field has a similar date/timestamp as 'created_at'.

# In order to check the status of individual URLs associated with this job, you then use the job ID (not UUID) and
# construct the following query:

$client->request('GET', '/urls/list.json?job_id=' . $response->[0]->{'job'}->{'id'});
$response = decode_json($client->responseContent());
print Dumper($response) . "\n";

# Here is the example output:

#$VAR1 = [
#          {
#            'url' => {
#                       'priority' => 10,
#                       'job_id' => 1180,
#                       'client_id' => undef,
#                       'time_at' => undef,
#                       'created_at' => '2009-05-12T19:23:57Z',
#                       'updated_at' => '2009-05-12T19:23:58Z',
#                       'url' => 'http://www.craigslist.org/',
#                       'url_status_id' => 1,
#                       'id' => 1198,
#                       'fingerprint_id' => undef
#                     }
#          },
#          {
#            'url' => {
#                       'priority' => 10,
#                       'job_id' => 1180,
#                       'client_id' => undef,
#                       'time_at' => undef,
#                       'created_at' => '2009-05-12T19:23:57Z',
#                       'updated_at' => '2009-05-12T19:23:58Z',
#                       'url' => 'http://www.woot.com/',
#                       'url_status_id' => 1,
#                       'id' => 1199,
#                       'fingerprint_id' => undef
#                     }
#          }
#        ];

# In general, when a URL has been visited, the URLs 'time_at' field will be populated with a timestamp in the form of
# number of microseconds since the epoch (e.g., 1203966522.974900).  Note that this is a *different* timestamp format
# than 'created_at' and 'updated_at'.

# Additionally, in order to figure out if the URL has been visited (with no suspicious activity) or if it has been
# found to be suspicious, you check the URLs 'url_status_id'.  You can get a human-readable version of this ID,
# by constructing the following query:

$client->request('GET', '/url_statuses/' . $response->[0]->{'url'}->{'url_status_id'} . '.json');
$response = decode_json($client->responseContent());
print Dumper($response) . "\n";

# Here is example output:
#$VAR1 = {
#          'url_status' => {
#                            'status' => 'queued',
#                            'id' => 1,
#                            'description' => 'URL is queued for processing.'
#                          }
#        };

# If the URL were flagged as suspicious, this would be the example output:
#$VAR1 = {
#          'url_status' => {
#                            'status' => 'suspicious',
#                            'id' => 3,
#                            'description' => 'URL was visisted and appears to contain malicious activity.'
#                          }
#        };
