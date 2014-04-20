class ErrorNotifier < ActionMailer::Base
  default from: "Depot Website <depot@depot.com>"
  default to: "Depot Admin <admin@depot.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.error_notifier.error.subject
  #
  def error(error)
    @error = error

    mail subject: 'A Website Error Has Occured'
  end
end
