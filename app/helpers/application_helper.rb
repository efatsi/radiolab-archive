module ApplicationHelper
  def seconds_to_description(sec)
    minute_seconds = [sec / 60 % 60, sec % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')

    if sec > 3600
      "#{sec / 3600}:#{minute_seconds}"
    else
      minute_seconds
    end
  end
end
