# Drone Tasks
#
# Used for cleaning up stale data in the drone database.

namespace :drone do
  desc "Flushes all queued URLs older than 5 minutes"
  task :flush_queued_urls => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    Url.update_all("url_status_id = " + UrlStatus.find_by_status("ignored").id.to_s, [ "url_status_id = :url_status_queued AND updated_at < :updated_at_lt", {:url_status_queued => UrlStatus.find_by_status("queued").id.to_s, :updated_at_lt => 5.minutes.ago}])
  end

  # TODO: Need client cleanup routines.
end

