class Address < Indirizzo::Address
    # for now, implicit/explicit string conversion is what is wanted, but ruby conversions can be weird...
    alias_method :to_str, :text
    alias_method :to_s, :text

    class IncompleteAddressError < StandardError
      attr_reader :address, :missing
      def initialize(address, missing = [])
        @address = address
        @missing = Array(missing)
        super("Address is missing #{self.missing.join(', ')}")
      end
    end
end
