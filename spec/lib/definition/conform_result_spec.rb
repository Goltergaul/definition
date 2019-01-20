# frozen_string_literal: true

describe Definition::ConformResult do
  describe ".error_hash" do
    subject(:error_hash) do
      described_class.new("foo", errors: errors).error_hash
    end

    context "with a error tree" do
      let(:errors) do
        [
          instance_double(Definition::ConformError,
                          error_path:       %w[user address street],
                          translated_error: "Value is too long"),
          instance_double(Definition::ConformError,
                          error_path:       %w[user address street],
                          translated_error: "Value does not match blah"),
          instance_double(Definition::ConformError,
                          error_path:       %w[user address city],
                          translated_error: "Is invalid"),
          instance_double(Definition::ConformError,
                          error_path:       %w[meta created_at],
                          translated_error: "Is not a time"),
          instance_double(Definition::ConformError,
                          error_path:       ["meta", "some_array", 2],
                          translated_error: "Is invalid")
        ]
      end

      before do
        errors.each do |error|
          allow(error).to receive(:leaf_errors)
            .and_return(error)
        end
      end

      it "generates a hash out of all error paths and their translated error messages" do
        expect(error_hash).to eql(
          "user" => {
            "address" => {
              "street" => ["Value is too long", "Value does not match blah"],
              "city"   => ["Is invalid"]
            }
          },
          "meta" => {
            "created_at" => ["Is not a time"],
            "some_array" => {
              2 => ["Is invalid"]
            }
          }
        )
      end
    end
  end
end
