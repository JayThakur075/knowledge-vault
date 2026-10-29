class DashboardController < ApplicationController
  def show
    user = Current.user
    @stats = Rails.cache.fetch([ "dashboard-stats", user.id, user.updated_at ], expires_in: 5.minutes) do
      { notes: user.notes.count, categories: user.categories.count, tags: user.tags.count, favorites: user.notes.favorites.count }
    end
    @note_count = @stats[:notes]
    @category_count = @stats[:categories]
    @tag_count = @stats[:tags]
    @favorite_count = @stats[:favorites]
    @recent_notes = user.notes.includes(:category, :tags).order(updated_at: :desc).limit(5)
    @notes_by_type = user.notes.group(:note_type).count
    @stale_note_count = Rails.cache.read([ "weekly-review", user.id ])
  end
end
