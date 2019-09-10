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
      # Default product name
      DEFAULT_PRODUCT = "chef".freeze
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
      WINDOWS_INSTALL_DIR = "cinc".freeze
    end
  end
end
