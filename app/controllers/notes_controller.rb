class NotesController < ApplicationController
  before_action :require_authentication
  before_action :set_note, only: %i[show edit update destroy]

  def index
    notes = Note.search_and_filter(Current.user, params)
    @page = [ params.fetch(:page, 1).to_i, 1 ].max
    @total_pages = [ (notes.count / 10.0).ceil, 1 ].max
    @page = [ @page, @total_pages ].min
    @notes = notes.limit(10).offset((@page - 1) * 10)
    @tags = Current.user.tags.order(:name)
    @categories = Current.user.categories.order(:name)
    @note_types = Current.user.notes.distinct.order(:note_type).pluck(:note_type).compact
  end

  def show
  end

  def new
    @note = Current.user.notes.new
  end

  def create
    @note = Current.user.notes.new(note_params.except(:category_id))
    @note.category = assign_category

    if ActiveRecord::Base.transaction { @note.save && update_tags }
      redirect_to @note, notice: "Note was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attributes = note_params.except(:category_id)

    if ActiveRecord::Base.transaction { @note.update(note_params.except(:category_id)) && @note.update!(category: assign_category) && update_tags }
      redirect_to @note, notice: "Note was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy

    redirect_to notes_path, notice: "Note was successfully deleted."
  end

  private

  def assign_category
    category_id = note_params[:category_id]

    if category_id.present?
      Current.user.categories.find(category_id)
    end
  end

  def set_note
    @note = Current.user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(
      :title,
      :content,
      :note_type,
      :favorite,
      :category_id
    )
  end

  def update_tags
    tag_names = params[:tag_names].to_s.split(",").map(&:strip).reject(&:blank?).uniq

    tags = tag_names.map do |name|
      Current.user.tags.find_or_create_by!(name: name.downcase)
    end

    @note.tags = tags
  end
end
