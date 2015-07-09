module ActionDispatch
  module Routing
    class MarkdownFormatter
      def initialize
        @buffer = []
      end

      def result
        @buffer.join("\n")
      end

      def section_title(title)
        @buffer << "\n#{title}:"
      end

      def section(routes)
        @buffer << draw_section(routes)
      end

      def header(routes)
        @buffer << draw_header(routes)
      end

      def no_routes
        @buffer << <<-MESSAGE.strip_heredoc
          You don't have any routes defined!

          Please add some routes in config/routes.rb.

          For more information about routes, see the Rails guide: http://guides.rubyonrails.org/routing.html.
          MESSAGE
      end

      private

      def draw_section(routes)
        header_lengths = ['Prefix', 'Verb', 'URI Pattern', 'Controller#Action' ].map(&:length)
        name_width, verb_width, path_width, reqs_width = widths(routes).zip(header_lengths).map(&:max)

        routes.map do |r|
          "| #{r[:name].rjust(name_width)} | #{r[:verb].ljust(verb_width)} | #{r[:path].ljust(path_width)} | #{r[:reqs].ljust(reqs_width)} |"
        end
      end

      def draw_header(routes)
        name_width, verb_width, path_width, reqs_width = widths(routes)

        header = "| #{"Prefix".rjust(name_width)} | #{"Verb".ljust(verb_width)} | #{"URI Pattern".ljust(path_width)} | #{"Controller#Action".ljust(reqs_width)} |\n"
        divider = "| #{'-' * name_width} | #{'-' * verb_width} | #{'-' * path_width} | #{'-' * reqs_width} |"
#        divider = "-" * header.size
        header + divider
      end

      def widths(routes)
        [routes.map { |r| r[:name].length }.max,
         routes.map { |r| r[:verb].length }.max,
         routes.map { |r| r[:path].length }.max,
         routes.map { |r| r[:reqs].length }.max]
      end
    end
  end
end
