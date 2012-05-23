module Raptor
  Markdown = Redcarpet::Markdown.new(Raptor::HTMLRenderer, {
    autolink: true,
    fenced_code_blocks: true
  })
end