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
  end

  def show
  end

  def new
    @note = Current.user.notes.new
  end

  def create
    @note = Current.user.notes.new(note_params)

    if @note.save
      redirect_to @note, notice: "Note was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @note.update(note_params)
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

  def set_note
    @note = Current.user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(
      :title,
      :content,
      :note_type,
      :favorite
    )
  end
end
