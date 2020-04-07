require_relative "product"

#
# If you are making a change to PRODUCT_MATRIX, please make sure
# you run `bundle exec rake matrix` at the home of this repository
# to update PRODUCT_MATRIX.md.
#
PRODUCT_MATRIX = Mixlib::Install::ProductMatrix.new do
  # Products in alphabetical order

  product "cinc" do
    product_name "Cinc Client"
    package_name "cinc"
  end

  product "cinc-auditor" do
    product_name "Cinc Auditor"
    package_name "cinc-auditor"
  end

  product "cinc-workstation" do
    product_name "Cinc Workstation"
    package_name "cinc-workstation"
  end
end
