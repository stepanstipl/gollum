require 'commonmarker'


wiki_options = {
} 
Precious::App.set(:wiki_options, wiki_options)

class Precious::App
  before do
    session['gollum.author'] = {
      :name => 'Wiki',
      :email => request.env['HTTP_X_AUTH_REQUEST_EMAIL']
    }
  end
end

Gollum::Hook.register(:post_commit, :hook_id) do |committer, sha1|
  `cd /wiki && git pull && git push`
end

GitHub::Markup::Markdown::MARKDOWN_GEMS['commonmarker'] = proc { |content, options: {}|
  commonmarker_parse_opts = []
  commonmarker_render_opts = [:GITHUB_PRE_LANG]
  commonmarker_exts = [:tagfilter, :autolink, :table, :strikethrough, :alerts]

  Commonmarker.to_html(content, options: {
    parse: { },
    render: { github_pre_lang: true },
    extension: { tagfilter: true, autolink: true, table: true, strikethrough: true, alerts: true} 
  })
}

