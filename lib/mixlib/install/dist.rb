module Mixlib
  class Install
    class Dist
      # This class is not fully implemented, depending it is not recommended!
      # Default project name
      PROJECT_NAME = "Cinc".freeze
      # Binary repository base endpoint
      PRODUCT_ENDPOINT = "http://packages.cinc.sh".freeze
      # Omnitruck endpoint
      OMNITRUCK_ENDPOINT = "https://omnitruck.cinc.sh".freeze
      # Commercial API endpoint
      COMMERCIAL_API_ENDPOINT = "".freeze
      # Trial API endpoint
      TRIAL_API_ENDPOINT = "".freeze
      # Default product name
      DEFAULT_PRODUCT = "cinc".freeze
      # Default download page URL
      DOWNLOADS_PAGE = "http://downloads.cinc.sh".freeze
      # Default github org
      GITHUB_ORG = "cinc-project".freeze
      # Bug report URL
      BUG_URL = "https://gitlab.com/cinc-project/mixlib-install/issues".freeze
      # Support ticket URL
      SUPPORT_URL = "https://gitlab.com/groups/cinc-project/-/issues".freeze
      # Resources URL
      RESOURCES_URL = "https://www.cinc.sh/support".freeze
      # MacOS volume name
      MACOS_VOLUME = "cinc_project".freeze
      # Windows install directory name
      OMNIBUS_WINDOWS_INSTALL_DIR = "cinc-project".freeze
      # Linux install directory name
      OMNIBUS_LINUX_INSTALL_DIR = "/opt"
      # Habitat Windows install directory name
      HABITAT_WINDOWS_INSTALL_DIR = "hab\\pkgs".freeze
      # Habitat Linux install directory name
      HABITAT_LINUX_INSTALL_DIR = "/hab/pkgs".freeze

      # Check if a license_id is for trial API
      # @param license_id [String] the license ID to check
      # @return [Boolean] true if license_id indicates trial API usage
      def self.trial_license?(license_id)
        !license_id.nil? && !license_id.to_s.empty? &&
          license_id.start_with?("free-", "trial-")
      end

      # Check if a license_id is for commercial API
      # @param license_id [String] the license ID to check
      # @return [Boolean] true if license_id indicates commercial API usage
      def self.commercial_license?(license_id)
        !license_id.nil? && !license_id.to_s.empty? &&
          !trial_license?(license_id)
      end
    end
  end
end
