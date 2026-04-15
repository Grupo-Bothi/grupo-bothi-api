# app/controllers/api/v1/companies_controller.rb
module Api
  module V1
    class CompaniesController < BaseController
      def show
        render json: current_company
      end

      def update
        current_company.update!(company_params)
        render json: current_company
      end

      private

      def company_params
        params.require(:company).permit(:name, :plan)
      end
    end
  end
end