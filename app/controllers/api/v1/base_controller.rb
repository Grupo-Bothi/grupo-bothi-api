# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      include Authenticable
      include Authorizable

      rescue_from ApiErrors::BaseError,          with: :handle_api_error
      rescue_from ActiveRecord::RecordNotFound,  with: :handle_not_found
      rescue_from ActiveRecord::RecordInvalid,   with: :handle_invalid

      before_action :authenticate_request

      private

      # Aplica orden a un scope. Solo permite columnas explícitamente declaradas.
      # Uso: apply_sort(scope, allowed: %i[name created_at])
      def apply_sort(scope, allowed:, default: :created_at, default_dir: :asc)
        column    = params[:sort_by]&.to_sym
        column    = allowed.include?(column) ? column : default
        direction = params[:sort_dir]&.downcase == "desc" ? :desc : default_dir
        scope.order(column => direction)
      end

      def current_company
        @current_company ||= begin
          company_id = request.headers["X-Company-Id"].presence
          raise ApiErrors::BadRequestError.new(details: I18n.t("auth.no_company")) if company_id.blank?
          current_user.companies.find(company_id)
        rescue ActiveRecord::RecordNotFound
          raise ApiErrors::ForbiddenError.new(details: I18n.t("auth.no_company"))
        end
      end

      def handle_api_error(error)
        render json: error.as_json, status: error.status
      end

      def handle_not_found
        render json: ApiErrors::NotFoundError.new(details: I18n.t("errors.resource_not_found")).as_json,
               status: :not_found
      end

      def handle_invalid(e)
        render json: ApiErrors::UnprocessableEntityError.new(
          details: e.record.errors.full_messages
        ).as_json, status: :unprocessable_entity
      end
    end
  end
end