module AnswersHelper

  def remove_head(str)
    str.slice!(0) if str.chars[0] == "-" || str.chars[0] == "+"
    return str
  end

  def th_color(sign)
    if sign == "+"
      return "green"
    elsif sign == "-"
      return "red"
    else
      return "normal"
    end
  end
end
