module PageStats
  extend ActiveSupport::Concern

  private

    def visit
      session[:page_visit] += 1
    rescue
      session[:page_visit] = 1
    ensure
      @visit = session[:page_visit]
    end

    def reset_count
      session[:page_visit] = 0
    end

end
