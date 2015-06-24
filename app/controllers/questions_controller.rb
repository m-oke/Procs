class QuestionsController < ApplicationController

  def index

  end
  def new

  end


  def create
    @question = Question.new(question_params)

    if @question.save
      flash.notice='問題登録しました'
      redirect_to controller: 'lessons', action:'show' , lesson_id: @lesson.id , id: @question.id
    else
      redirect_to controller: 'lessons', action:'new'
    end
  end

  private
  def question_params
    params.require(:question).permit(
      :title,
      :content,
      :input_description,
      :output_description,
      :run_time_limit,
      :memory_usage_limit,
      :cpu_usage_limit,
      samples_attributes: [:input,:output],
      test_data_attributes: [:input,:output]
    )

  end

end
