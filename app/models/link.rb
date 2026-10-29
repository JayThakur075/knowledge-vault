class Link < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :category, optional: true
  has_many :link_tags, dependent: :destroy
  has_many :tags, through: :link_tags

  validates :title, :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid HTTP or HTTPS URL" }
  validate :category_belongs_to_user

  def safe_url
    parsed_url = URI.parse(url)
    parsed_url.to_s if %w[http https].include?(parsed_url.scheme) && parsed_url.host.present?
  rescue URI::InvalidURIError
    nil
  end

  private

  def category_belongs_to_user
    return if category.nil? || category.user == user

    errors.add(:category, "must belong to the same user")
  end
end
