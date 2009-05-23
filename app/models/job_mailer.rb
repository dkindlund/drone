class JobMailer < ActionMailer::Base

  def job_created(hash)
    setup_email(hash)
    @subject          += 'Job Submitted: ' + hash["uuid"].to_s
    @body[:created_at] = hash["created_at"]
  end

  def job_completed(hash)
    setup_email(hash)
    @body[:completed_at] = hash["completed_at"]
    @body[:suspicious_activity] = "NO"

    calculate_urls_by_type(hash)
    if (@body[:url_statistics].key?("suspicious") ||
        @body[:url_statistics].key?("compromised"))
      @subject += "ALERT - "
      @body[:suspicious_activity] = "YES"
      # TODO: Need to make this configurable.
      @bcc = ["kindlund@mitre.org", "darien@kindlund.com"]
    end
    @subject += 'Job Completed: ' + hash["uuid"].to_s
  end

  protected
  def setup_email(hash)
    @recipients       = hash["recipients"]
    @from             = "#{ADMIN_EMAIL}"
    @subject          = "[#{SITE_DOMAIN}] "
    @sent_on          = Time.now
    @body[:urls]      = hash["urls"]
    @body[:uuid]      = hash["uuid"].to_s
    @body[:uuid_url]  = "#{SITE_URL}/jobs/list?uuid=" + hash["uuid"].to_s
    @body[:url_count] = hash["urls"].size.to_i
  end

  def calculate_urls_by_type(hash)
    @body[:url_statistics] = {}
    @body[:urls_by_type] = {}
    hash["urls"].each do |u|
      next if (!u.key?("url_status") || !u["url_status"].key?("status"))
      if !@body[:url_statistics].key?(u["url_status"]["status"])
        @body[:url_statistics][u["url_status"]["status"]] = 1
        @body[:urls_by_type][u["url_status"]["status"]] = [u]
      else
        @body[:url_statistics][u["url_status"]["status"]] += 1
        @body[:urls_by_type][u["url_status"]["status"]] << u
      end
    end 
  end
end
