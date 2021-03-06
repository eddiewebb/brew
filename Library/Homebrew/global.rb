require "pathname"
require "English"

require "pp"
require "extend/ARGV"

ARGV.extend(HomebrewArgvExtension)

HOMEBREW_PRODUCT = ENV["HOMEBREW_PRODUCT"]
HOMEBREW_VERSION = ENV["HOMEBREW_VERSION"]
HOMEBREW_WWW = "https://brew.sh".freeze

require "config"
require "extend/git_repository"

HOMEBREW_REPOSITORY.extend(GitRepositoryExtension)

require "rbconfig"

RUBY_PATH = Pathname.new(RbConfig.ruby)
RUBY_BIN = RUBY_PATH.dirname

HOMEBREW_USER_AGENT_CURL = ENV["HOMEBREW_USER_AGENT_CURL"]
HOMEBREW_USER_AGENT_RUBY = "#{ENV["HOMEBREW_USER_AGENT"]} ruby/#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}".freeze
HOMEBREW_USER_AGENT_FAKE_SAFARI = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/602.4.8 (KHTML, like Gecko) Version/10.0.3 Safari/602.4.8".freeze

require "extend/fileutils"

module Homebrew
  extend FileUtils

  class << self
    attr_writer :failed

    def failed?
      @failed ||= false
      @failed == true
    end

    attr_writer :raise_deprecation_exceptions, :auditing

    def raise_deprecation_exceptions?
      @raise_deprecation_exceptions == true
    end

    def auditing?
      @auditing == true
    end
  end
end

HOMEBREW_PULL_API_REGEX = %r{https://api\.github\.com/repos/([\w-]+)/([\w-]+)?/pulls/(\d+)}
HOMEBREW_PULL_OR_COMMIT_URL_REGEX = %r[https://github\.com/([\w-]+)/([\w-]+)?/(?:pull/(\d+)|commit/[0-9a-fA-F]{4,40})]

require "forwardable"
require "PATH"

ENV["HOMEBREW_PATH"] ||= ENV["PATH"]
ORIGINAL_PATHS = PATH.new(ENV["HOMEBREW_PATH"]).map do |p|
  begin
    Pathname.new(p).expand_path
  rescue
    nil
  end
end.compact.freeze

HOMEBREW_INTERNAL_COMMAND_ALIASES = {
  "ls" => "list",
  "homepage" => "home",
  "-S" => "search",
  "up" => "update",
  "ln" => "link",
  "instal" => "install", # gem does the same
  "uninstal" => "uninstall",
  "rm" => "uninstall",
  "remove" => "uninstall",
  "configure" => "diy",
  "abv" => "info",
  "dr" => "doctor",
  "--repo" => "--repository",
  "environment" => "--env",
  "--config" => "config",
}.freeze

require "set"

require "os"
require "extend/pathname"

require "extend/module"
require "extend/predicable"
require "extend/string"

require "constants"
require "exceptions"
require "utils"

require "official_taps"
require "tap"
require "tap_constants"

if !ARGV.include?("--no-compat") && !ENV["HOMEBREW_NO_COMPAT"]
  require "compat"
end
