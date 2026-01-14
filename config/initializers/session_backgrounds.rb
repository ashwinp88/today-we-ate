module TodayWeAte
  module SessionBackgrounds
    extend self

    SUPPORTED_EXTENSIONS = /\.(png|jpe?g|webp|avif|svg)\z/i
    DIRECTORIES = [
      { path: Rails.root.join("app", "assets", "background"), logical_prefix: nil },
      { path: Rails.root.join("app", "assets", "backgrounds"), logical_prefix: nil },
      { path: Rails.root.join("app", "assets", "images", "background"), logical_prefix: "background" },
      { path: Rails.root.join("app", "assets", "images", "backgrounds"), logical_prefix: "backgrounds" }
    ].freeze

    def candidates
      DIRECTORIES.flat_map do |entry|
        path = entry[:path]
        next [] unless Dir.exist?(path)

        Dir.children(path).grep(SUPPORTED_EXTENSIONS).map do |filename|
          entry[:logical_prefix].present? ? File.join(entry[:logical_prefix], filename) : filename
        end
      end.uniq
    end
  end
end

Rails.configuration.x.session_background_candidates = TodayWeAte::SessionBackgrounds.candidates
Rails.logger.info("[BG] Loaded #{Rails.configuration.x.session_background_candidates.size} session backgrounds")
