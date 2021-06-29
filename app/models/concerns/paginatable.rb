module Paginatable
  extend ActiveSupport::Concern

  module ClassMethods
    def paginate(params)
      per_page = 10
      self.page(params[:_end].to_i / per_page).order("#{params[:_sort]} #{params[:_order]}").per(per_page)
    end
  end
end
