class OnlyAjaxRequest
  def self.matches?(request)
    request.xhr?
  end
end
