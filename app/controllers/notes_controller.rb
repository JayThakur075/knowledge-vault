class NotesController < ApplicationController
  before_action :require_authentication
  before_action :set_note, only: %i[show edit update destroy]

  def index
    @notes = Current.user.notes.recent

    if params[:query].present?
      query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query])}%"

      @notes = @notes.where(
        "title LIKE :query OR content LIKE :query",
        query: query
      )
    end

    if params[:note_type].present?
      @notes = @notes.where(note_type: params[:note_type])
    end

    if params[:favorite] == "true"
      @notes = @notes.favorites
    end

    if params[:category_id].present?
      @notes = @notes.where(
        category: Current.user.categories.find(params[:category_id])
      )
    end
  end

  def show
  end

  def new
    @note = Current.user.notes.new
  end

  def create
    attributes = note_params.except(:category_id)
    @note = Current.user.notes.new(attributes)
    @note.category = assign_category

    if @note.save
      update_tags
      redirect_to @note, notice: "Note was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attributes = note_params.except(:category_id)

    if @note.update(attributes)
      @note.category = assign_category
      @note.save!
      update_tags

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
      Tag.find_or_create_by!(name: name)
    end

    @note.tags = tags
  end
end
