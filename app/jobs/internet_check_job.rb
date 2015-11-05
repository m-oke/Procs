class InternetCheckJob < ActiveJob::Base
  queue_as :plagiarism

  def perform(question_id,lesson_id)
    result = Array.new(0,Array.new(4,0))
    lesson = Lesson.find_by(:id => lesson_id)
    students = User.where(:id => lesson.user_lessons.where(:is_teacher => false).pluck(:user_id))
    students.each do |s|
      result = []
      answer = Answer.where(:lesson_id => lesson_id, :student_id => s['id'], :question_id => question_id).last
      if answer == nil
        next
      end
      pre_store_result = InternetCheckResult.where(:answer_id => answer.id, :title => nil)
      pre_store_result_count = pre_store_result.count
      if pre_store_result_count == 1
        plagiarism_check = PlagiarismInternetCheck.new(question_id, lesson_id, s['id'], result)
        plagiarism_check.check
      end
    end
  end

end
