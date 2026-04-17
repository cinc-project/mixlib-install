#
# Author:: Patrick Wright (<patrick@chef.io>)
# Copyright:: Copyright (c) 2016 Chef, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "spec_helper"
require "mixlib/install/options"
require "mixlib/install/backend/package_router"
require "mixlib/install/version"

context "Mixlib::Install::Backend::PackageRouter all channels", :vcr do
  let(:channel) { :stable }
  let(:product_name) { "cinc" }
  let(:product_version) { :latest }
  let(:platform) { nil }
  let(:platform_version) { nil }
  let(:architecture) { nil }
  let(:user_agent_headers) { nil }
  let(:pv_compat) { nil }
  let(:include_metadata) { nil }

  let(:options) do
    {}.tap do |opt|
      opt[:product_name] = product_name
      opt[:product_version] = product_version
      opt[:channel] = channel
      opt[:platform_version_compatibility_mode] = pv_compat if pv_compat
      opt[:include_metadata] = include_metadata if include_metadata
      opt[:user_agent_headers] = user_agent_headers if user_agent_headers
      opt[:platform] = platform if platform
      opt[:platform_version] = platform_version if platform_version
      opt[:architecture] = architecture if architecture
    end
  end

  let(:mixlib_options) { Mixlib::Install::Options.new(options) }
  let(:package_router) { Mixlib::Install::Backend::PackageRouter.new(mixlib_options) }
  let(:artifact_info) { package_router.info }

  context "for cinc stable latest without platform" do
    it "returns an array of artifacts" do
      expect(artifact_info).to be_a(Array)
      expect(artifact_info).not_to be_empty
      expect(artifact_info.first).to be_a(Mixlib::Install::ArtifactInfo)
    end
  end

  context "for cinc stable latest with ubuntu platform" do
    let(:platform) { "ubuntu" }
    let(:platform_version) { "20.04" }
    let(:architecture) { "x86_64" }

    it "returns one artifact with normalized fields" do
      expect(artifact_info).to be_a(Mixlib::Install::ArtifactInfo)
      expect(artifact_info.product_name).to eq("cinc")
      expect(artifact_info.product_description).to eq("Cinc Client")
      expect(artifact_info.platform).to eq("ubuntu")
      expect(artifact_info.platform_version).to eq("20.04")
      expect(artifact_info.architecture).to eq("x86_64")
      expect(artifact_info.sha256).to match(/^[0-9a-f]{64}$/)
      expect(artifact_info.url).to include("packages.cinc.sh")
      expect(artifact_info.url).to include("/files/stable/cinc/")
    end
  end

  context "with metadata enabled" do
    let(:platform) { "ubuntu" }
    let(:platform_version) { "20.04" }
    let(:architecture) { "x86_64" }
    let(:include_metadata) { true }

    it "returns metadata fields when available" do
      expect(artifact_info).to be_a(Mixlib::Install::ArtifactInfo)
      expect([String, NilClass]).to include(artifact_info.license_content.class)
      expect([Hash, NilClass]).to include(artifact_info.software_dependencies.class)
    end
  end

  context "for a non-existent version" do
    let(:platform) { "ubuntu" }
    let(:platform_version) { "20.04" }
    let(:architecture) { "x86_64" }
    let(:product_version) { "99.99.99" }

    it "raises ArtifactsNotFound" do
      expect { artifact_info }.to raise_error(Mixlib::Install::Backend::ArtifactsNotFound)
    end
  end

  context "available versions" do
    it "returns versions sorted ascending by semver" do
      versions = package_router.available_versions
      expect(versions).to be_a(Array)
      expect(versions).not_to be_empty
      parsed = versions.map { |v| Mixlib::Versioning.parse(v) }
      expect(parsed).to eq(parsed.sort)
    end
  end

  context "user agents" do
    it "always includes default header" do
      expect(package_router.create_http_request("/").get_fields("user-agent")).to include("mixlib-install/#{Mixlib::Install::VERSION}")
    end

    context "with custom agents" do
      let(:user_agent_headers) { ["foo/bar", "someheader"] }

      it "sets custom header" do
        expect(package_router.create_http_request("/").get_fields("user-agent")).to include(/foo\/bar someheader/)
      end
    end
  end

  context "for cinc-server latest" do
    let(:product_name) { "cinc-server" }
    let(:platform) { "ubuntu" }
    let(:platform_version) { "20.04" }
    let(:architecture) { "x86_64" }

    it "uses cinc-server package path" do
      expect(artifact_info).to be_a(Mixlib::Install::ArtifactInfo)
      expect(artifact_info.url).to include("/files/stable/cinc-server/")
    end
  end
end
