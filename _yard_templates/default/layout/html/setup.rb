def javascripts
  # Remove jquery as we already load jquery in the site.
  super - %w(js/jquery.js)
end
