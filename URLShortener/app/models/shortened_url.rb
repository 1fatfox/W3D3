# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint(8)        not null, primary key
#  long_url   :string           not null
#  short_url  :string
#  user_id    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  validates :long_url, presence: true

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: 'User'

  has_many :visitors,
    -> { distinct },
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: 'Visit'

  def self.random_code(long_url, user_id)
    shorter = SecureRandom.urlsafe_base64(16, false)

    until ShortenedUrl.exists?(shorter) == false
      shorter = SecureRandom.urlsafe_base64(16, false)
    end

    shorty = ShortenedUrl.create!(
              long_url: long_url,
              user_id: user_id,
              short_url: shorter)

    Visit.record_visit!(user_id, shorty.id)
  end

  def num_clicks
    Visit.where(shortened_url_id: self.id).count
  end

  def num_uniques
    visitors.where(shortened_url_id: self.id).count
  end

  def num_recent_uniques

  end


end
