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
require "mixlib/install/product_matrix"

describe Mixlib::Install::ProductMatrix do
  describe "#initialize" do
    it "creates a new ProductMatrix instance" do
      matrix = described_class.new {}
      expect(matrix).to be_a(described_class)
    end

    it "accepts a block for configuration" do
      matrix = described_class.new do
        product "test-product" do
          product_name "Test Product"
        end
      end

      expect(matrix).to be_a(described_class)
    end
  end

  describe "#product" do
    let(:matrix) do
      described_class.new do
        product "test-product" do
          product_name "Test Product"
          package_name "test-package"
        end
      end
    end

    it "defines a new product in the matrix" do
      expect(matrix.lookup("test-product")).not_to be_nil
      expect(matrix.lookup("test-product").product_name).to eq("Test Product")
    end
  end

  describe "#lookup" do
    context "with existing product" do
      it "returns the product for cinc" do
        product = PRODUCT_MATRIX.lookup("cinc")
        expect(product).not_to be_nil
        expect(product.product_name).to eq("Cinc Client")
      end

      it "returns the product for cinc-server" do
        product = PRODUCT_MATRIX.lookup("cinc-server")
        expect(product).not_to be_nil
        expect(product.product_name).to eq("Cinc Server")
      end
    end

    context "with non-existing product" do
      it "returns nil for unknown product" do
        expect(PRODUCT_MATRIX.lookup("non-existing-product")).to be_nil
      end
    end

    context "with version parameter" do
      it "returns product with version context" do
        product = PRODUCT_MATRIX.lookup("cinc", "17.0.0")
        expect(product).not_to be_nil
      end
    end
  end

  describe "#products" do
    it "returns an array of all product keys" do
      products = PRODUCT_MATRIX.products
      expect(products).to be_an(Array)
      expect(products).to include("cinc")
      expect(products).to include("cinc-server")
      expect(products).to include("omnibus-toolchain")
    end

    it "does not include duplicate products" do
      products = PRODUCT_MATRIX.products
      expect(products.uniq.size).to eq(products.size)
    end
  end

  describe "#products_available_on_downloads_site" do
    it "returns products available on downloads site" do
      products = PRODUCT_MATRIX.products_available_on_downloads_site
      expect(products).to be_a(Hash)
      expect(products.keys).to include("cinc")
      expect(products.keys).to include("cinc-server")
    end

    it "does not include products with :not_available downloads URL" do
      products = PRODUCT_MATRIX.products_available_on_downloads_site
      # Products with downloads_product_page_url :not_available should not be included
      expect(products.keys).not_to include("angry-omnibus-toolchain")
    end
  end

  describe "product attributes" do
    context "for cinc product" do
      let(:cinc_product) { PRODUCT_MATRIX.lookup("cinc") }

      it "has correct product_name" do
        expect(cinc_product.product_name).to eq("Cinc Client")
      end

      it "has correct package_name" do
        expect(cinc_product.package_name).to eq("cinc")
      end

      it "does not have ctl_command" do
        expect(cinc_product.ctl_command).to be_nil
      end
    end

    context "for cinc-server product" do
      let(:cinc_server_product) { PRODUCT_MATRIX.lookup("cinc-server") }

      it "has correct product_name" do
        expect(cinc_server_product.product_name).to eq("Cinc Server")
      end
    end
  end

  describe "version-specific attributes" do
  end

  describe "#lookup as accessor" do
    it "can be used to retrieve products" do
      cinc_product = PRODUCT_MATRIX.lookup("cinc")
      expect(cinc_product).not_to be_nil
      expect(cinc_product.product_name).to eq("Cinc Client")
    end
  end

  describe "edge cases" do
    context "with nil product key" do
      it "returns nil" do
        expect(PRODUCT_MATRIX.lookup(nil)).to be_nil
      end
    end

    context "with empty string product key" do
      it "returns nil" do
        expect(PRODUCT_MATRIX.lookup("")).to be_nil
      end
    end
  end
end
