#
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
require "mixlib/install/product"

context "Mixlib::Install::Product" do
  context "for product_name when using strings" do
    let(:product) do
      Mixlib::Install::Product.new("product") do
        product_name "test-product"
      end
    end

    it "accepts and returns the value correctly" do
      expect(product.product_key).to eq("product")
      expect(product.product_name).to eq("test-product")
    end

    it "returns nil for unset properties" do
      expect(product.package_name).to eq(nil)
    end

    it "errors for non-existent properties" do
      expect { product.address }.to raise_error(StandardError)
    end
  end

  context "for package_name when using block" do
    let(:product) do
      Mixlib::Install::Product.new("product") do
        package_name do |version|
          "my-version-#{version}"
        end
      end
    end

    it "accepts and returns the value correctly without a version" do
      expect(product.package_name).to eq("my-version-")
    end

    it "accepts and returns the value correctly with a version" do
      product.version("11.0.0")
      expect(product.package_name).to eq("my-version-11.0.0")
    end

    it "returns nil for unset properties" do
      expect(product.product_name).to eq(nil)
    end

    it "errors for non-existent properties" do
      expect { product.address }.to raise_error(StandardError)
    end
  end

  context "for package_name when using block and string" do
    let(:product) do
      Mixlib::Install::Product.new("product") do
        package_name "my-name" do |version|
          "my-version-#{version}"
        end
      end
    end

    it "should error" do
      expect { product }.to raise_error(StandardError)
    end
  end

  it "has version_for defined" do
    expect(Mixlib::Install::Product.new("product") {}).to respond_to(:version_for)
  end

  it "has the DSL methods for all required properties" do
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:product_key)
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:product_name)
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:package_name)
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:ctl_command)
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:config_file)
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:install_path)
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:omnibus_project)
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:github_repo)
    expect(Mixlib::Install::Product::DSL_PROPERTIES).to include(:downloads_product_page_url)
  end
end

context "PRODUCT_MATRIX" do
  let(:product_key) do
    PRODUCT_MATRIX.lookup(product_name, version).product_key
  end

  let(:package_name) do
    PRODUCT_MATRIX.lookup(product_name, version).package_name
  end

  let(:omnibus_project) do
    PRODUCT_MATRIX.lookup(product_name, version).omnibus_project
  end

  let(:ctl_command) do
    PRODUCT_MATRIX.lookup(product_name, version).ctl_command
  end

  let(:config_file) do
    PRODUCT_MATRIX.lookup(product_name, version).config_file
  end

  let(:install_path) do
    PRODUCT_MATRIX.lookup(product_name, version).install_path
  end

  let(:github_repo) do
    PRODUCT_MATRIX.lookup(product_name, version).github_repo
  end

  let(:downloads_product_page_url) do
    PRODUCT_MATRIX.lookup(product_name, version).downloads_product_page_url
  end

  CINC_PRODUCTS = %w{
    cinc
    cinc-auditor
    cinc-foundation
    cinc-workstation
    cinc-server
    omnibus-toolchain
  }

  it "has entries for all #{CINC_PRODUCTS.length} products" do
    expect(PRODUCT_MATRIX.products).to eq CINC_PRODUCTS
  end

  it "can lookup entries for all #{CINC_PRODUCTS.length} products" do
    CINC_PRODUCTS.each do |p|
      expect(PRODUCT_MATRIX.lookup(p).product_name).to be_a(String)
    end
  end

  it "returns nil when looking up a non-existent product" do
    expect(PRODUCT_MATRIX.lookup("no-such-project")).to be_nil
  end

  it "returns nil for unset parameters" do
    expect(PRODUCT_MATRIX.lookup("cinc").ctl_command).to be_nil
  end
end
