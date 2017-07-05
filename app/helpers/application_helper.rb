module ApplicationHelper

  def full_to_half(str)
      if str
        str.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
      else
        ""
      end
  end

end
