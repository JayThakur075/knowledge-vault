class LinksController < ApplicationController
  before_action :set_link, only: %i[show edit update destroy]

  def index
    @links = Current.user.links.includes(:category, :tags).order(updated_at: :desc)
    if params[:query].present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query])}%"
      @links = @links.left_joins(:tags).where("links.title LIKE :term OR links.description LIKE :term OR links.url LIKE :term OR tags.name LIKE :term", term: term).distinct
    end
    @links = @links.where(category_id: Current.user.categories.select(:id).where(id: params[:category_id])) if params[:category_id].present?
    @links = @links.joins(:tags).where(tags: { id: Current.user.tags.where(name: params[:tag]).select(:id) }) if params[:tag].present?
  end

  def show
  end

  def new
    @link = Current.user.links.new
  end

  def create
    @link = Current.user.links.new(link_params.except(:category_id))
    @link.category = owned_category
    if ActiveRecord::Base.transaction { @link.save && update_tags }
      redirect_to @link, notice: "Link saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if ActiveRecord::Base.transaction { @link.update(link_params.except(:category_id)) && @link.update!(category: owned_category) && update_tags }
      redirect_to @link, notice: "Link updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @link.destroy
    redirect_to links_path, notice: "Link deleted."
  end

  private

  def set_link
    @link = Current.user.links.find(params[:id])
  end

  def link_params
    params.require(:link).permit(:title, :url, :description, :category_id)
  end

  def owned_category
    Current.user.categories.find(link_params[:category_id]) if link_params[:category_id].present?
  end

  def update_tags
    names = params[:tag_names].to_s.split(",").map { |name| name.strip.downcase }.reject(&:blank?).uniq
    @link.tags = names.map { |name| Current.user.tags.find_or_create_by!(name: name) }
  end
end
