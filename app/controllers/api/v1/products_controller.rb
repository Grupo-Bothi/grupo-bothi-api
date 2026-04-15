# app/controllers/api/v1/products_controller.rb
module Api
  module V1
    class ProductsController < BaseController
      before_action :set_product, only: [:show, :update, :destroy]

      def index
        products = current_company.products.search(params[:search])
        products = products.where("stock <= min_stock") if params[:low_stock] == "true"
        products = apply_sort(products, allowed: %i[name sku stock min_stock unit_cost created_at], default: :name)
        @pagy, @products = pagy(products)
        render json: paginate_response(@pagy, @products)
      end

      def show
        render json: @product
      end

      def create
        product = current_company.products.create!(product_params)
        render json: product, status: :created
      end

      def update
        @product.update!(product_params)
        render json: @product
      end

      def destroy
        @product.destroy!
        render json: { message: I18n.t("products.deleted") }
      end

      private

      def set_product
        @product = current_company.products.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:sku, :name, :stock, :min_stock, :unit_cost)
      end
    end
  end
end