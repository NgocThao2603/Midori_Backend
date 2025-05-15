class Example < ApplicationRecord
  belongs_to :vocabulary

  has_many :example_tokens, -> { order(:token_index) }, dependent: :destroy
  has_many :questions, dependent: :destroy

  # Van dang bi loi
  def sorted_tokens(hidden_part = nil)
    # Nếu không có hidden_part thì trả về theo token_index
    return example_tokens.order(:token_index) if hidden_part.blank?
    # Tìm question có hidden_part này để lấy correct_answers
    question = questions.find_by(hidden_part: hidden_part)
    return example_tokens.order(:token_index) unless question&.correct_answers

    # Parse correct_answers từ JSON và lọc/sắp xếp tokens theo thứ tự
    correct_tokens = JSON.parse(question.correct_answers) rescue []
    example_tokens
      .where(jp_token: correct_tokens)
      .sort_by { |token| correct_tokens.index(token.jp_token) }
  end
end
