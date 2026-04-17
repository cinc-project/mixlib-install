#
# Author:: Patrick Wright (<patrick@chef.io>)
# Copyright:: Copyright (c) 2015-2018 Chef Software, Inc.
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
require "mixlib/install"

context "Mixlib::Install::Backend", :vcr do
  let(:channel) { nil }
  let(:product_name) { nil }
  let(:product_version) { nil }
  let(:platform) { nil }
  let(:platform_version) { nil }
  let(:architecture) { nil }

  let(:info) do
    Mixlib::Install.new(
      channel: channel,
      product_name: product_name,
      product_version: product_version,
      platform: platform,
      platform_version: platform_version,
      architecture: architecture
    ).artifact_info
  end

  let(:available_versions) do
    Mixlib::Install.new(
      channel: channel,
      product_name: product_name
    ).available_versions
  end

  def check_platform_info(data)
    expect(data.platform).to eq(platform)
    expect(data.platform_version).to eq(platform_version)
    expect(data.architecture).to eq(architecture)
  end

  shared_examples_for "the right artifact info" do
    it "has the right properties" do
      expect(info.url).to include(Mixlib::Install::Dist::PRODUCT_ENDPOINT)
      expect(info.url).to include("/files/")
      expect(info.sha256).to match(/^[0-9a-f]{64}$/)
      expect(info.version).to match(/\d+\.\d+\.\d+/)
    end

    it "has the right platform info" do
      check_platform_info(info)
    end
  end

  shared_examples_for "the right artifact list info" do
    it "has the correct number of platforms" do
      # Currently we have 7 platforms in stable and 6 platforms in current.
      # We can add more in the future
      expect(info.map(&:platform).uniq.length).to be >= 6

      info.each do |artifact_info|
        expect(artifact_info).to be_a(Mixlib::Install::ArtifactInfo)
      end
    end

    it "has the right properties for artifacts" do
      info.each do |artifact_info|
        expect(artifact_info.url).to include(Mixlib::Install::Dist::PRODUCT_ENDPOINT)
        expect(artifact_info.url).to include("/files/")
        expect(artifact_info.sha256).to match(/^[0-9a-f]{64}$/)
        expect(artifact_info.version).to match(/\d+\.\d+\.\d+/)
      end
    end
  end

  context "for stable channel with latest version" do
    let(:product_name) { "cinc" }
    let(:channel) { :stable }
    let(:product_version) { :latest }

    context "without platform info" do
      it_behaves_like "the right artifact list info"
    end

    context "with platform info" do
      let(:platform) { "ubuntu" }
      let(:platform_version) { "20.04" }
      let(:architecture) { "x86_64" }

      it_behaves_like "the right artifact info"
    end
  end

  context "for stable channel with :latest" do
    let(:product_name) { "cinc" }
    let(:channel) { :stable }
    let(:product_version) { :latest }

    context "without platform info" do
      it_behaves_like "the right artifact list info"
    end

    context "with platform info" do
      let(:platform) { "ubuntu" }
      let(:platform_version) { "20.04" }
      let(:architecture) { "x86_64" }

      it_behaves_like "the right artifact info"
    end
  end

  [:current, :unstable].each do |channel|
    context "for #{channel} channel with :latest" do
      let(:product_name) { "cinc" }
      let(:channel) { channel }
      let(:product_version) { :latest }

      it "raises ArtifactsNotFound" do
        expect { info }.to raise_error(Mixlib::Install::Backend::ArtifactsNotFound)
      end
    end
  end

  context "available_versions" do
    let(:product_name) { "cinc" }

    context "with :stable channel" do
      let(:channel) { :stable }

      it "returns the list of available versions" do
        expect(available_versions).to be_a(Array)
        expect(available_versions).not_to be_empty
        expect(available_versions.first).to match(/\d+\.\d+\.\d+/)
      end
    end
  end

end
