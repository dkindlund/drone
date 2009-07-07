class UrlObserver < ActiveRecord::Observer

  # For URL status changes, we update the corresponding, applicable
  # UrlStatistic(s) objects, if they already exist.
  def before_update(url)

    # Disable automatic timestamps.
    UrlStatistic.record_timestamps = false

    if (!url.time_at.nil? && url.changes.key?("url_status_id") && !UrlStatistic.find(:first, :conditions => [":time_at >= url_statistics.created_at AND :time_at <= url_statistics.updated_at", {:time_at => Time.at(url.time_at.to_f)}]).nil?)

      url_status_queued  = UrlStatus.find_by_status("queued").id
      url_status_id_from = url.changes["url_status_id"].first
      url_status_id_to   = url.changes["url_status_id"].last

   
      # Figure out the UrlStatistic entries to decrement.
      # We only decrement if the from status isn't queued.
      if (url_status_id_from != url_status_queued) 
        url_statistics = UrlStatistic.find(:all, :conditions => ["url_statistics.url_status_id = :url_status_id AND :time_at >= url_statistics.created_at AND :time_at <= url_statistics.updated_at",
                                                                 {:url_status_id => url_status_id_from, 
                                                                  :time_at       => Time.at(url.time_at.to_f)}])
        url_statistics.each do |url_statistic|
          if (url_statistic.count > 0)
            url_statistic.decrement!(:count)
          end
        end
      end

      # Figure out the UrlStatistic entries to increment.
      url_statistics = UrlStatistic.find(:all, :conditions => ["url_statistics.url_status_id = :url_status_id AND :time_at >= url_statistics.created_at AND :time_at <= url_statistics.updated_at",
                                                               {:url_status_id => url_status_id_to, 
                                                                :time_at       => Time.at(url.time_at.to_f)}])
      url_statistics.each do |url_statistic|
        url_statistic.increment!(:count)
      end 
    end
  end
end
