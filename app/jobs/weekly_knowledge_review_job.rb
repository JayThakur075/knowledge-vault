class WeeklyKnowledgeReviewJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      stale_count = user.notes.where("updated_at < ?", 30.days.ago).count
      Rails.cache.write([ "weekly-review", user.id ], stale_count, expires_in: 8.days)
    end
  end
end
