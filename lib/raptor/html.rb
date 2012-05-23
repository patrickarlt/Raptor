module Raptor
  class HTMLRenderer < Redcarpet::Render::HTML
    def block_code(code, language)
      highlighted = CodeRay.scan(code, language.to_sym).div(:line_numbers => :table)
      "<code class='#{language}'>#{highlighted}</code>"
    end
  end
end
