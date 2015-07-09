require 'markdown_formatter'
desc 'Print out all defined routes in match order, with names in markdown format. Target specific controller with CONTROLLER=x.'
task routes_md: :environment do
  all_routes = Rails.application.routes.routes
  require 'action_dispatch/routing/inspector'
  inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)
  puts inspector.format(ActionDispatch::Routing::MarkdownFormatter.new, ENV['CONTROLLER'])
end
