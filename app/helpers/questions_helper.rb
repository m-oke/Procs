module QuestionsHelper
  def show_local(filepath)
    code = File.open(filepath, 'r:utf-8')
    return code
  end
end
