require 'pathname'

module Minitest
  module Filesystem
    class Matcher
      def initialize(root, &block)
        @actual_tree = MatchingTree.new(root)
        @expected_tree = block
        @is_matching = true
      end

      def file(file)
        exists?(file, :file)
      end

      def link(link, target=nil)
        exists?(link, :symlink) && is_target_correct?(link, target)
      end

      def dir(dir, &block)
        matcher = self.class.new(@actual_tree.expand_path(dir), &block) if block_given?

        exists?(dir, :directory) && subtree(matcher)
      end

      def match_found?
        instance_eval(&@expected_tree)
        @is_matching
      end

      def message
        @failure_msg || ""
      end

      private

      # Checks existance of specified entry.
      # Existance is defined both in terms of presence and of being of the
      # right type (e.g. a file being a file and not a directory)
      def exists?(entry, kind=:entry)
        entry(entry, kind) && is_a?(entry, kind)
      end

      # Checks if an entry with given name exists.
      def entry(entry, kind=:entry)
        update_matching_status(
          @actual_tree.include?(entry),
          not_found_msg_for(entry, kind))
      end

      # Checks if a specific entry (supposed to exist) is of a given kind.
      def is_a?(entry, kind)
        update_matching_status(
          @actual_tree.is_a?(entry, kind),
          mismatch_msg_for(entry, kind))
      end

      # Checks the target of a symbolic link.
      def is_target_correct?(link, target)
        return true unless target

        update_matching_status(
          @actual_tree.has_target?(link, target),
          link_target_mismatch_msg_for(link, target))
      end

      def subtree(matcher)
        update_matching_status(matcher.match_found?, matcher.message) if matcher
      end

      def update_matching_status(check, msg)
        @is_matching = @is_matching && check
        set_failure_msg(msg) unless @is_matching

        @is_matching
      end

      def not_found_msg_for(entry, kind)
        "Expected `#{@actual_tree.root}` to contain #{kind} `#{entry}`."
      end

      def mismatch_msg_for(entry, kind)
        "Expected `#{entry}` to be a #{kind}, but it was not."
      end

      def link_target_mismatch_msg_for(link, target)
        "Expected `#{link}` to point to `#{target}`, but it pointed to #{@actual_tree.follow_link(link)}"
      end

      def set_failure_msg(msg)
        @failure_msg ||= msg
      end

      class MatchingTree
        attr_reader :root

        def initialize(root)
          @root = Pathname.new(root)
          @tree = expand_tree_under @root
        end

        def include?(entry)
          @tree.include?(expand_path(entry))
        end

        def is_a?(entry, kind)
          (expand_path entry).send("#{kind}?")
        end
        
        def has_target?(entry, target)
          expand_path(target) == follow_link(entry)
        end

        def expand_path(file)
          @root + Pathname.new(file)
        end

        def follow_link(link)
          Pathname.new(File.readlink(expand_path(link)))
        end

        private
        
        def expand_tree_under(dir)
          Pathname.glob(dir.join("**/*"))
        end
      end
    end
  end
end
