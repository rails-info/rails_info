module Grit
  class Repo
    def diff(a, b, *paths)
      diff = self.git.native('diff', { 'no-ext-diff' => true }, a, b, '--', *paths)

      if diff =~ /diff --git a/
        diff = diff.sub(/.*?(diff --git a)/m, '\1')
      else
        diff = ''
      end
      
      Diff.list_from_string(self, diff)
    end
  end
end

module RailsInfo
  module VersionControl
  end
end